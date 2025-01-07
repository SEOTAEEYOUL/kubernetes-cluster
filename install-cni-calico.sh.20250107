#!/bin/bash


# Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"

# Deploying Calico on an RBAC enabled cluster, first apply the ClusterRole and ClusterRoleBinding specs:
# kubectl apply -f https://docs.projectcalico.org/v2.5/getting-started/kubernetes/installation/rbac.yaml
# kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml

# Install Calico
# # Installing with the Kubernetes API datastore—50 nodes or less
# curl -LO https://docs.projectcalico.org/v2.5/getting-started/kubernetes/installation/hosted/calico.yaml
# curl https://docs.projectcalico.org/manifests/calico.yaml -O
# kubectl apply -f calico.yaml



# # Install Calico
# kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
# kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml


# 2025-01-07
curl -O https://raw.githubusercontent.com/gasida/KANS/main/kans3/calico-kans.yaml
kubectl apply -f calico-kans.yaml
curl -O https://github.com/projectcalico/calico/releases/download/v3.29.1/calicoctl-linux-amd64 -o calicoctl
chmod +x calicoctl && mv calicoctl /usr/bin
calicoctl version
