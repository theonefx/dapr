#!/bin/bash

SHELL_FLODER=$(cd "$(dirname "$0")";pwd)

rm -rf $SHELL_FLODER/dist/*
rm -rf $SHELL_FLODER/tests/e2e/**/dist
rm -rf $SHELL_FLODER/tests/e2e/**/*.log

helm uninstall dapr dapr-kafka dapr-redis -n $DAPR_NAMESPACE
make delete-test-namespace

kubectl delete MutatingWebhookConfiguration/dapr-sidecar-injector

sleep 5

echo -e "============================================================cleanup finish============================================================\n\n"

make create-test-namespace

make setup-test-env-redis
make setup-test-env-kafka

echo -e "============================================================service installed============================================================\n\n"

# Build Linux binaries
make build-linux

echo -e "============================================================dapr build done============================================================\n\n"

# Build Docker image with Linux binaries
make docker-build

# Push docker image to your dockerhub registry
make docker-push

echo "wait 10 seconds to for docker registry sync data with dapr"
sleep 10

# Deploy Dapr runtime to your cluster
make docker-deploy-k8s

echo -e "============================================================push dapr 2 docker repo done============================================================\n\n"

make setup-disable-mtls

make setup-test-components

echo -e "============================================================cluster config done============================================================\n\n"

# build e2e apps docker image under apps
#make build-e2e-app-all

# push e2e apps docker image to docker hub
#make push-e2e-app-all

echo "============================================================e2e app push done============================================================"