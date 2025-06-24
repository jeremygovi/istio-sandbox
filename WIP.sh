
export DOCKER_DEFAULT_PLATFORM=linux/arm64
 
cat <<EOF | kind create cluster --image=kindest/node:v1.31.1 --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 31437
    hostPort: 8080
    protocol: TCP
  - containerPort: 31438
    hostPort: 8443
    protocol: TCP
EOF



# kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.3.0" | kubectl apply -f -

# kubectl kustomize "github.com/nginx/nginx-gateway-fabric/config/crd?ref=v2.0.1" | kubectl apply -f -

# kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/refs/tags/v2.0.1/deploy/default/deploy.yaml


# kubectl apply -f httpbin.yaml


# cillium install 
# cillium status



kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml

kubectl apply -f- <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: example
  namespace: metallb-system
spec:
  addresses:
  - 172.18.255.200-172.18.255.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb-system
EOF
