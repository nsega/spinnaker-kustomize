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
	@echo "Applying Kubernetes configuration..."
	kubectl apply -k .
	@echo "✓ Configuration applied successfully"

.PHONY: prune
prune: ## Apply Kubernetes configuration via kustomize and prune old. ** CAUTION **
	kubectl apply -k . --prune --all

.PHONY: expose
expose: ## Start port-forwarding for Spinnaker services (Deck UI at :9000, Gate API at :8084)
	@echo "Starting port-forward for Deck UI (Spinnaker Frontend) on port 9000..."
	kubectl port-forward -n spinnaker service/deck 9000 &
	@echo "Starting port-forward for Gate API (Spinnaker Backend) on port 8084..."
	kubectl port-forward -n spinnaker service/gate 8084 &
	@echo "✓ Port-forwarding started successfully"
	@echo "→ Access Spinnaker UI at: http://localhost:9000"
	@echo "→ Gate API available at: http://localhost:8084"

.PHONY: kill-expose
kill-expose: ## Stop port-forwarding processes (Deck UI: 9000, Gate API: 8084)
	@echo "Stopping Deck UI port-forward (port 9000)..."
	-pkill -f "kubectl port-forward.*spinnaker.*9000" || echo "Deck UI process was not running"
	@echo "Stopping Gate API port-forward (port 8084)..."
	-pkill -f "kubectl port-forward.*spinnaker.*8084" || echo "Gate API process was not running"
	@echo "✓ All port-forward processes have been terminated"

.PHONY: delete
delete: ## Delete KinD cluster
	kind delete cluster --name spinnaker

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


