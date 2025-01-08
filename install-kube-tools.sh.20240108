#!/bin/bash


# ---------------------------------------------------------------
# apt 패키지 인덱스를 업데이트하고, Kubernetes apt 저장소가 필요로 하는 패키지를 설치합니다.
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl jq tmux

# 구글 클라우드의 공개 사이닝 키를 다운로드 한다.
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 쿠버네티스 apt 리포지터리를 추가한다.
curl -fsSL https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# apt 패키지를 업데이트하고, kubelet, kubeadm, kubectl을 설치합니다.
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl

# 그리고 kubelet, kubeadm, kubectl이 자동으로 업그레이드 되는 일이 없게끔 버전을 고정합니다.
sudo apt-mark hold kubelet kubeadm kubectl
# ---------------------------------------------------------------
 

 # conteaienrnetworking-plugins 설치
sudo apt install containernetworking-plugins

# Node-Shell (https://github.com/kvaps/kubectl-node-shell)
curl -LO https://github.com/kvaps/kubectl-node-shell/raw/master/kubectl-node_shell
chmod +x ./kubectl-node_shell
sudo mv ./kubectl-node_shell /usr/local/bin/kubectl-node_shell
# ----------------------------------------------------------
