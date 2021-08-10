#!/bin/bash

Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"

# Deploying Calico on an RBAC enabled cluster, first apply the ClusterRole and ClusterRoleBinding specs:
kubectl apply -f https://docs.projectcalico.org/v2.5/getting-started/kubernetes/installation/rbac.yaml

# Install Calico
curl -LO https://docs.projectcalico.org/v2.5/getting-started/kubernetes/installation/hosted/calico.yaml
kubectl apply -f calico.yaml 