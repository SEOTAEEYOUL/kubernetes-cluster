#!/bin/bash

set -e  # Exit on error

# install k8s master ( Start cluster )
HOST_NAME=$(hostname -s)

# Install kubernetes via kubeadm.
# kubeadm init --apiserver-advertise-address=$NODE_IP
kubeadm init --apiserver-advertise-address=$MASTER_NODE_IP --apiserver-cert-extra-sans=$MASTER_NODE_IP  --node-name $HOST_NAME --pod-network-cidr=$POD_CIDR --service-cidr=$SERVICE_CIDR

# copying credentials to regular user - vagrant
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


export KUBECONFIG=/etc/kubernetes/admin.conf

# Hostname -i must return a routable address on second (non-NATed) network interface.
# @see http://kubernetes.io/docs/getting-started-guides/kubeadm/#limitations
sed "s/127.0.0.1.*m/$NODE_IP m/" -i /etc/hosts

# Export k8s cluster token to an external file.
OUTPUT_FILE=/vagrant/join.sh
rm -rf /vagrant/join.sh
kubeadm token create --print-join-command > /vagrant/join.sh
chmod +x $OUTPUT_FILE

echo "join.sh"
cat /vagrant/join.sh