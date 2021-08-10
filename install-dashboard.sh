

# Install Dashboard:
curl -sSL https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml|kubectl apply -f -

# for cluster dashboard to appear as part of "kubectl cluster-info"
kubectl label svc kubernetes-dashboard -n kube-system kubernetes.io/cluster-service=true kubernetes.io/name=k8s-dashboard

kubectl cluster-info 