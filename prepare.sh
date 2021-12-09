#!/bin/bash

SHELL_FLODER=$(cd "$(dirname "$0")";pwd)

echo -e "====start cleanup"
rm -rf "$SHELL_FLODER"/dist/*
rm -rf "$SHELL_FLODER"/tests/e2e/**/dist
rm -rf "$SHELL_FLODER"/tests/e2e/**/*.log

#helmls=$(helm ls -n "$DAPR_NAMESPACE")
#
#if echo "${helmls}"|grep -q "dapr-redis"; then
#	echo "has dapr-redis uninstall =========="
#	helm uninstall dapr-redis "$DAPR_NAMESPACE"
#fi

#if echo "${helmls}"|grep -q "dapr-kafka"; then
#	helm uninstall dapr-kafka "$DAPR_NAMESPACE"
#fi

#helm uninstall dapr -n "$DAPR_NAMESPACE"

#make delete-test-namespace > /dev/zero 2>&1
#kubectl delete MutatingWebhookConfiguration/dapr-sidecar-injector > /dev/zero 2>&1

#make create-test-namespace

#make setup-test-env-redis
#make setup-test-env-kafka

echo -e "====start build & push"

export GOARCH=arm64
export GOOS=linux
export TARGET_ARCH=arm64
export TARGET_OS=linux

# Build Linux binaries
#make build-linux

# Build Docker image with Linux binaries
#make docker-build

# Push docker image to your dockerhub registry
#make docker-push

echo -e "====dapr build & push done, start deploy"

# Deploy Dapr runtime to your cluster
#make docker-deploy-k8s

echo -e "====dapr deploy done"

echo -e "====start build test app"

#make setup-disable-mtls

#make setup-test-components

export E2E_TEST_APPS=actorjava actordotnet actorpython actorphp

# build e2e apps docker image under apps
make build-e2e-app-all

# push e2e apps docker image to docker hub
make push-e2e-app-all

echo "====e2e app push done"