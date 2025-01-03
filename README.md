# istio-sandbox

## Step 0

Have a running local k8s cluster like minikube, k3s, k3d, Docker Desktop... (oui, c'est tout)

## Install argocd (one tool to rule them all)

```
kubectl create namespace argocd
kubectl apply -n argocd -f argocd_install.yaml

```

## Access the dashboard

### install ingress controller

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

```

### Install ingress

```
kubectl apply -n argocd -f argocd_ingress.yaml
```

### Points your /etc/hosts

Add this to your /etc/hosts:

```
127.0.0.1 argocd.local kiali.local prometheus.local grafana.local fleetman.local service-a.local service-b.local
```

## Tell argocd installs all the stuff

```
kubectl apply -n argocd -f entrypoint.yaml
```

<!-- ## Configure Kiali to access remote istio

```
kubectl config view --minify --flatten --context=arn:aws:eks:eu-west-3:915812500603:cluster/evoyageurs-dev-paris > /tmp/kubeconfig
kubectl create secret generic kiali-kubeconfig \
  --from-file=/tmp/kubeconfig \
  -n istio-system
kubectl create secret generic aws-credentials \
  --from-file=credentials=/Users/jeremy_govi/.aws/credentials \
  --dry-run=client -o yaml | kubectl apply -n istio-system -f -
``` -->

## Access URLs

### ArgoCD:

URL: https://argocd.local/
username: admin

password:

```
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
```

### Kiali:

URL: https://kiali.local/kiali/

### Grafana:

URL: https://grafana.local/

username: admin

password: DjaimPatagel
