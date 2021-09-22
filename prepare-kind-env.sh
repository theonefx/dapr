#!/bin/bash

export REGISTRY_PORT=5000
export REGISTRY_NAME=kind-registry
export DAPR_REGISTRY=localhost=5000/dapr
export DAPR_TAG=dev
export DAPR_NAMESPACE=dapr-tests
export GOVER=1.17
export GOROOT=/opt/hostedtoolcache/go/1.17.1/x64
export DAPR_CONTAINER_LOG_PATH=~/tmp/dapr/container_logs
export TEST_OUTPUT_FILE_PREFIX=~/tmp/dapr/test_report

rm -rf ~/tmp/dapr

mkdir -p $DAPR_CONTAINER_LOG_PATH
mkdir -p $TEST_OUTPUT_FILE_PREFIX

docker stop $REGISTRY_NAME

kind delete cluster

cat > kind.yaml <<EOF
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
nodes:
- role: control-plane
  image: kindest/node:v1.22.0@sha256:b8bda84bb3a190e6e028b1760d277454a72267a5454b57db34437c34a588d047
- role: worker
  image: kindest/node:v1.22.0@sha256:b8bda84bb3a190e6e028b1760d277454a72267a5454b57db34437c34a588d047
- role: worker
  image: kindest/node:v1.22.0@sha256:b8bda84bb3a190e6e028b1760d277454a72267a5454b57db34437c34a588d047
- role: worker
  image: kindest/node:v1.22.0@sha256:b8bda84bb3a190e6e028b1760d277454a72267a5454b57db34437c34a588d047
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:$REGISTRY_PORT"]
    endpoint = ["http://$REGISTRY_NAME:$REGISTRY_PORT"]
EOF

cat kind.yaml

kind create cluster --config kind.yaml

docker run -d -p $REGISTRY_PORT:$REGISTRY_PORT --name $REGISTRY_NAME --rm registry:2

docker network connect "kind" $REGISTRY_NAME

docker login http://$REGISTRY_NAME:$REGISTRY_PORT -u theonefx -p 123456