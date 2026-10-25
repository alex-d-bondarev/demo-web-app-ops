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
