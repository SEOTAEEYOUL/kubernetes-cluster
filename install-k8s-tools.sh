#!/bin/bash


# ---------------------------------------------------------------
# apt 패키지 인덱스를 업데이트하고, Kubernetes apt 저장소가 필요로 하는 패키지를 설치합니다.
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Ubuntu 22.04 이전 릴리스에서는 /etc/apt/keyring이 기본적으로 존재하지 않는다. 
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
if [ -x /etc/apt/keyrings ]
then
  echo "Directory exists"
else
  echo "Directory does not exist"
  sudo mkdir -p /etc/apt/keyrings
  sudo mkdir -p -m 755 /etc/apt/keyrings
fi

# 구글 클라우드의 공개 사이닝 키를 다운로드 한다.
# - 시간대별 변경사항
# 2023년 8월 15일: 새로운 커뮤니티 관리 패키지 저장소 발표
# 2023년 8월 31일: 기존 저장소 공식 지원 중단
# 2023년 9월 13일: 기존 저장소 동결
# 2024년 3월 4일: 기존 저장소 완전 제거
# sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# 쿠버네티스 apt 리포지터리를 추가한다.
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 패키지 업데이트
sudo apt-get update

# 설치 가능한 버전 확인
# sudo apt-cache madison kubeadm

# kubeadm, kubelet, kubectl 설치
sudo apt-get install -y kubelet kubeadm kubectl

# 그리고 kubelet, kubeadm, kubectl이 자동으로 업그레이드 되는 일이 없게끔 버전을 고정합니다.
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet
# ---------------------------------------------------------------


# conteaienrnetworking-plugins 설치
sudo apt install containernetworking-plugins

# # Node-Shell (https://github.com/kvaps/kubectl-node-shell)
# curl -LO https://github.com/kvaps/kubectl-node-shell/raw/master/kubectl-node_shell
# chmod +x ./kubectl-node_shell
# sudo mv ./kubectl-node_shell /usr/local/bin/kubectl-node_shell
# ----------------------------------------------------------
