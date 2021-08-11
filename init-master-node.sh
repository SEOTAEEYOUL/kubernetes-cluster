#!/bin/bash


# install k8s master ( Start cluster )
HOST_NAME=$(hostname -s)

# Install kubernetes via kubeadm.
# kubeadm init --apiserver-advertise-address=$NODE_IP
kubeadm init --apiserver-advertise-address=$NODE_IP --apiserver-cert-extra-sans=$NODE_IP  --node-name $HOST_NAME --pod-network-cidr=$POD_CIDR --service-cidr=$SERVICE_CIDR

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


# Kubernetes Metrics Server
export DOWNLOAD_URL=$(curl -Ls "https://api.github.com/repos/kubernetes-sigs/metrics-server/releases/latest" | jq -r .tarball_url)
export DOWNLOAD_VERSION=$(grep -o '[^/v]*$' <<< $DOWNLOAD_URL)
curl -Ls $DOWNLOAD_URL -o metrics-server-$DOWNLOAD_VERSION.tar.gz
mkdir metrics-server-$DOWNLOAD_VERSION
tar -xzf metrics-server-$DOWNLOAD_VERSION.tar.gz --directory metrics-server-$DOWNLOAD_VERSION --strip-components 1
kubectl apply -f metrics-server-$DOWNLOAD_VERSION/deploy/1.8+/
kubectl get deployment metrics-server -n kube-system