# istio-sandbox

## Step 0

Have a running local k8s cluster like minikube, k3s, k3d, Docker Desktop... (oui, c'est tout)

### With KIND

```
kind create cluster --name istio-kind --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: istio-kind
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30080
        hostPort: 80
        protocol: TCP
      - containerPort: 30443
        hostPort: 443
        protocol: TCP
EOF

```

### Points your /etc/hosts

Add this to your /etc/hosts:

```
127.0.0.1 argocd.local kiali.local prometheus.local grafana.local fleetman.local service-a.local service-b.local
```

## Install argocd (one tool to rule them all)

```
kubectl create namespace argocd
kubectl label namespace argocd istio-injection=enabled
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd \
  --version 8.1.1 \
  --namespace argocd \
  --set server.extraArgs="{--insecure}"

```

## Install istio components

```
kubectl create namespace istio-system
kubectl label namespace istio-system istio-injection=enabled

kubectl apply -n argocd -f istio-crds.yaml
kubectl apply -n argocd -f istiod.yaml
kubectl apply -n argocd -f istio-ingressgateway.yaml

```

## Install argocd gateway

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout argocd.local.key \
  -out argocd.local.crt \
  -subj "/CN=argocd.local"

kubectl create -n istio-system secret tls argocd-cert \
  --key=argocd.local.key \
  --cert=argocd.local.crt

rm -f argocd.local.key argocd.local.crt

kubectl apply -n argocd -f argocd_external_access.yaml
```

## Tell argocd installs all the stuff

```
for HOST_CERT in kiali grafana prometheus
do
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ${HOST_CERT}.local.key \
    -out ${HOST_CERT}.local.crt \
    -subj "/CN=${HOST_CERT}.local"

  kubectl create -n istio-system secret tls ${HOST_CERT}-cert \
    --key=${HOST_CERT}.local.key \
    --cert=${HOST_CERT}.local.crt
done

rm -f *.local.key *.local.crt


kubectl create namespace ivts
kubectl label namespace ivts istio-injection=enabled

kubectl apply -n argocd -f entrypoint.yaml
```

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
