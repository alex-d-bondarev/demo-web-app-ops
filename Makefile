.PHONY: help lint template kubeconform unittest check-all

HELM_IMAGE := alpine/helm:3.14.0
UNITTEST_IMAGE := helmunittest/helm-unittest:latest
CHART_DIR := deploy
ARGOCD_DIR := argocd

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  help          Show this help message"
	@echo "  lint          Lint Helm chart"
	@echo "  template      Render Helm templates"
	@echo "  kubeconform   Validate ArgoCD manifests with kubeconform"
	@echo "  unittest      Run helm unittest"
	@echo "  check-all     Run all checks in CI order (lint -> template -> kubeconform -> unittest)"

lint:
	docker run --rm -v "$(PWD)/$(CHART_DIR):/chart" $(HELM_IMAGE) lint /chart

template:
	docker run --rm -v "$(PWD)/$(CHART_DIR):/chart" $(HELM_IMAGE) \
		template demo-web-app /chart --namespace demo-web-app --values /chart/values.yaml

kubeconform:
	docker run --rm -v "$(PWD)/$(ARGOCD_DIR):/manifests" alpine:3.19 \
		sh -c "apk add --no-cache curl >/dev/null && curl -sL https://github.com/yannh/kubeconform/releases/download/v0.6.7/kubeconform-linux-arm64.tar.gz | tar xz && ./kubeconform -strict -summary -ignore-missing-schemas /manifests/*.yaml"

unittest:
	docker run --rm -v "$(PWD)/$(CHART_DIR):/chart" $(UNITTEST_IMAGE) /chart

check-all: lint template kubeconform unittest