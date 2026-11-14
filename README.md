# demo-web-app-ops

Manage alex-d-bondarev/demo-web-app deployments

## How to

1. Clone this repository (or at least save the [argocd-app.yaml](./argocd-app.yaml)) to machine with kubectl and argocd access
2. Run the following:
```
argocd login ${ARGO_CD_HOST}:${ARGO_CD_PORT}
argocd repo add https://github.com/alex-d-bondarev/demo-web-app-ops.git
kubectl apply -f argocd-demo-web-app.yaml
```

## Hosts

Use `http://demo-web-app.local` or `https://demo-web-app.local` after deployment to access frontend

---

## CI

### GitHub Actions Workflow

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `.github/workflows/ci.yaml` | PR + push to main | Quick validation → k3d integration test (sequential) |

### What the CI does

1. **Quick Validation** (runs first)
   - Lint Helm chart (`helm lint`)
   - Render Helm templates (`helm template`)
   - Validate ArgoCD manifests with `kubeconform`
   - Run Helm unittest (`helm unittest`)

2. **k3d Integration Test** (runs after quick-check passes)
   - Spin up k3d cluster — Kubernetes (k3s) in Docker
   - Install ArgoCD — applies official manifests
   - Install Envoy Gateway CRDs — required before ArgoCD syncs
   - Deploy App of Apps — applies `argocd/app-of-apps.yaml`
   - Wait for readiness — envoy-gateway (wave 0) → demo-web-app (wave 1)
   - Verify resources — Gateway + HTTPRoute exist

### Running locally (lint & template only)

**Option A: Helm CLI (recommended for development)**
```bash
# Install: https://helm.sh/docs/intro/install/
# Install kubeconform: https://github.com/yannh/kubeconform#installation
# Install helm unittest: helm plugin install https://github.com/helm-unittest/helm-unittest

# Lint Helm chart
helm lint deploy/

# Render Helm templates
helm template demo-web-app deploy/ --namespace demo-web-app --values deploy/values.yaml

# Validate ArgoCD manifests with kubeconform
kubeconform -strict -summary -ignore-missing-schemas argocd/*.yaml

# Run helm unittest
helm unittest deploy/
```

**Option B: Docker (no local install needed)**
```bash
# Lint
docker run --rm -v "$PWD/deploy:/chart" alpine/helm:3.14.0 lint /chart

# Template
docker run --rm -v "$PWD/deploy:/chart" alpine/helm:3.14.0 \
  template demo-web-app /chart --namespace demo-web-app --values /chart/values.yaml
```

**Option C: Makefile (wraps Option B)**
```bash
# Individual checks
make lint          # helm lint
make template      # helm template
make kubeconform   # validate ArgoCD manifests
make unittest      # helm unittest

# Run all in CI order
make check-all     # lint -> template -> kubeconform -> unittest
```

### GitHub Actions CI requirements (for full k3d integration test)

- Docker running on the runner
- ~2 GB free RAM for the k3d cluster
- Runs automatically on push/PR to main via `.github/workflows/ci.yaml`