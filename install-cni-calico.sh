#!/bin/bash

# # master.k8s 라는 도메인으로 hosts 파일에 등록 함.
# sudo sh -c "echo $K8S_IP $K8S_HOST >> /etc/hosts"

# # Install Containerd & K8S
# sudo apt-get update && sudo apt-get dist-upgrade -y
# sudo $SCRIPT_PATH/install-containerd.sh
# sudo $SCRIPT_PATH/install-k8s.sh $K8S_VERSION



# # K8S Node Init
# sudo systemctl restart containerd
# sudo systemctl restart kubelet
# cat << EOF > conf.yaml
# apiVersion: kubeadm.k8s.io/v1beta3
# kind: InitConfiguration
# localAPIEndpoint:
#   advertiseAddress: "${K8S_IP}"
#   bindPort: 6443
# ---
# apiVersion: kubelet.config.k8s.io/v1beta1
# kind: KubeletConfiguration
# cgroupDriver: containerd
# EOF
# sudo kubeadm init --config=conf.yaml --v=5 > kubeinit.log && cat kubeinit.log

# # Copy K8S Config
# echo export KUBECONFIG=/etc/kubernetes/admin.conf >> $HOME/.bashrc

# Install Calico
# Migrate Calico to an operator-managed installation
# https://docs.tigera.io/calico/latest/operations/operator-migration#operator-migration
# kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/tigera-operator.yaml

curl https://github.com/projectcalico/calico/releases/download/v3.29.1/calicoctl-linux-amd64 -o calicoctl
chmod +x calicoctl && mv calicoctl /usr/local/bin
ls -l /usr/local/bin
calicoctl version
