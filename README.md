# demo-web-app-ops

Manage alex-d-bondarev/demo-web-app deployments

## How to

1. Clone this repository to machine with kubectl and argocd access
2. Run the following:
```
minikube start --cpus=4 --memory=6144
minikube tunnel
# or a similar alternative in case of a different k8s app

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl apply -f argocd/app-of-apps.yaml
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
