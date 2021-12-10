#!/bin/bash

# ------------------------------------------------------------
# Copyright (c) Microsoft Corporation and Dapr Contributors.
# Licensed under the MIT License.
# ------------------------------------------------------------

# This script will create a new kind cluster locally

# Usage: prepare-kind-env.sh

export DAPR_TMP_BASE=~/tmp/dapr
export REGISTRY_PORT=5000
export REGISTRY_NAME=kind-registry
export DAPR_REGISTRY=localhost=5000/dapr
export DAPR_TAG=dev
export DAPR_NAMESPACE=dapr-tests
export GOVER=1.17
export GOROOT=/opt/hostedtoolcache/go/1.17.1/x64
export DAPR_CONTAINER_LOG_PATH=$DAPR_TMP_BASE/container_logs
export TEST_OUTPUT_FILE_PREFIX=$DAPR_TMP_BASE/test_report

rm -rf $DAPR_TMP_BASE
mkdir -p $DAPR_CONTAINER_LOG_PATH
mkdir -p $TEST_OUTPUT_FILE_PREFIX

# registry
running="$(docker inspect -f '{{.State.Running}}' "${REGISTRY_NAME}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
	echo "registry not exist create new one"
	docker run -d -p $REGISTRY_PORT:$REGISTRY_PORT --name $REGISTRY_NAME --rm registry:2
fi

echo "login registry"
docker login http://$REGISTRY_NAME:$REGISTRY_PORT -u dapr -p 123456

# kind
cluster="$(kind get clusters 2>&1 | grep dapr)"

if [ -n "$cluster" ]; then
	echo "existing cluster, now delete"
	kind delete cluster --name=dapr
fi

echo "create new kind cluster named [dapr]"
cat <<EOF | kind create cluster --config=-
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
name: dapr
nodes:
- role: control-plane
  image: kindest/node:v1.22.0@sha256:b8bda84bb3a190e6e028b1760d277454a72267a5454b57db34437c34a588d047
- role: worker
  image: kindest/node:v1.22.0@sha256:b8bda84bb3a190e6e028b1760d277454a72267a5454b57db34437c34a588d047
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."${REGISTRY_NAME}:${REGISTRY_PORT}"]
    endpoint = ["http://${REGISTRY_NAME}:${REGISTRY_PORT}"]
EOF

docker network connect "kind" $REGISTRY_NAME

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "${REGISTRY_NAME}:${REGISTRY_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF
