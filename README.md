# istio-sandbox

## Step 0

Install argocd cli:

```
brew install argocd
```

Have a running local k8s cluster

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
127.0.0.1 argocd.local
```

### Access the dashboard

```
argocd admin initial-password -n argocd

```

Then, go to https://argocd.local/

User: admin
Password: the one you had in the previous command
