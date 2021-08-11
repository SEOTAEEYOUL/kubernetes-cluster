#!/bin/bash

Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"

# Deploying Calico on an RBAC enabled cluster, first apply the ClusterRole and ClusterRoleBinding specs:
# kubectl apply -f https://docs.projectcalico.org/v2.5/getting-started/kubernetes/installation/rbac.yaml
kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml

# Install Calico
# # Installing with the Kubernetes API datastore—50 nodes or less
# curl -LO https://docs.projectcalico.org/v2.5/getting-started/kubernetes/installation/hosted/calico.yaml
curl https://docs.projectcalico.org/manifests/calico.yaml -O
sed -i -e "s?192.128.0.0/16?$POD_CIDR?g" calico.yaml
kubectl apply -f calico.yaml