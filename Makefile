# Spinnaker local dev Makefile

# OUTPUT contains rendered kustomize chart. Useful to diff kustomize changes.
OUTPUT ?= spinnaker.yaml

# Make defaults
SHELL := /usr/bin/env bash -o errexit -o nounset -o pipefail -c
all: help

.PHONY: create
create: ## Create KinD cluster
	kind create cluster --name spinnaker --config kind.yml

.PHONY: build
build: ## Build Kubernetes configuration via kustomize, optionally: 'OUTPUT=example.yaml'
	kubectl kustomize -o $(OUTPUT)

.PHONY: apply
apply: ## Apply Kubernetes configuration via kustomize
	kubectl apply -k .
    kubectl create secret generic kubeconfig --from-file=kubeconfig=.kube/config -n spinnaker
    kubectl create secret generic googleconfig --from-file=gke_account.json=.gcp/gke_account.json -n spinnaker

.PHONY: prune
prune: ## Apply Kubernetes configuration via kustomize and prune old. ** CAUTION **
	kubectl apply -k . --prune --all

.PHONY: expose
expose: ## Port Forward Deck UI and Gate API
	kubectl port-forward -n spinnaker service/deck 9000 &
	kubectl port-forward -n spinnaker service/gate 8084 &

.PHONY: delete
delete: ## Delete KinD cluster
	kind delete cluster --name spinnaker

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


