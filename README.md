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
| `.github/workflows/ci.yaml` | PR + push to main | Quick validation: lint + template + kubeconform |

### What the CI does

1. **Lint Helm chart** (`helm lint`)
2. **Render Helm templates** (`helm template`)
3. **Validate ArgoCD manifests** with `kubeconform`

### Running locally

**Option A: Helm CLI (recommended for development)**
```bash
# Install: https://helm.sh/docs/intro/install/
# Install kubeconform: https://github.com/yannh/kubeconform#installation

# Lint Helm chart
helm lint deploy/

# Render Helm templates
helm template demo-web-app deploy/ --namespace demo-web-app --values deploy/values.yaml

# Validate ArgoCD manifests with kubeconform
kubeconform -strict -summary -ignore-missing-schemas argocd/*.yaml
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

# Run all in CI order
make check-all     # lint -> template -> kubeconform
```