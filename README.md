# istio-sandbox

## Step 0: prerequisites

ℹ️ **NOTE**: It's important to wait a minute between each kubectl apply command to let the time to ressources to be operational. A N+1 command can depend on the N one to be ready or to setup some resources. Please, check that all is OK before continuing.

### Install some base components

- kind
- helm
- vi/nano
- kubectl
- openssl (only to generate the first certificates to let argocd to automate all the others)

### Create your k8s cluster

With KIND (for example)

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
127.0.0.1 argocd.local kiali.local prometheus.local grafana.local fleetman.local service-a.local service-b.local bookinfo.local
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
  --set-string configs.cm."exec\.enabled"="true" \
  --set server.extraArgs="{--insecure}"

```

## Install istio components

```
kubectl create namespace istio-system
kubectl label namespace istio-system istio-injection=enabled

kubectl apply -n argocd -f zz_manual_install_apps/istio-crds.yaml
kubectl apply -n argocd -f zz_manual_install_apps/istiod.yaml
kubectl apply -n argocd -f zz_manual_install_apps/istio-ingressgateway.yaml

```

## Generate All first needed certificates and install it as secrets in kubernetes

```
for HOST_CERT in argocd kiali grafana prometheus
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
```

## Tell argocd to install all the platform mandatory stuff

```
kubectl apply -n argocd -f zz_manual_install_apps/platform-entrypoint.yaml
```

## Install argocd gateway

```
kubectl apply -n argocd -f zz_manual_install_apps/argocd_external_access.yaml
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

URL: https://grafana.local/ (username: admin, password: admin)

## (OPTIONAL) Install some apps from the catalog

You can install some interesting apps from the catalog in the [`business_apps`](./business_apps/) directory.
Just pick one and install it with:

```
kubectl apply -n argocd -f business_apps/<YOUR_AWESOME_APP>.yaml
```

And check the argocd UI to see the magic

## Troubleshooting

### SSL Error host xxx.local returns SSL_ERROR_SYSCALL

ex:

```
curl -vvv -Ik https://bookinfo.local/productpage
* Host bookinfo.local:443 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:443...
* connect to ::1 port 443 from ::1 port 56632 failed: Connection refused
*   Trying 127.0.0.1:443...
* Connected to bookinfo.local (127.0.0.1) port 443
* ALPN: curl offers h2,http/1.1
* (304) (OUT), TLS handshake, Client hello (1):
* LibreSSL SSL_connect: SSL_ERROR_SYSCALL in connection to bookinfo.local:443
* Closing connection
curl: (35) LibreSSL SSL_connect: SSL_ERROR_SYSCALL in connection to bookinfo.local:443
```

-> TLS certificate must be in the same namespace as Istio ingress (in our case: istio-system)
Put the Certificate and the Gateway on the same place too (if possible)
