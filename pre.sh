#!/bin/bash

# 필수 포트 확인
sudo nc 127.0.0.1 6443 -v


# Update apt registry.
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl # software-properties-common

# Install essential utilities
apt-get install -y \
    jq \
    tmux \
    net-tools \
    ipvsadm \
    ipset \
    nfs-common \
    iptables \
    arptables \
    ebtables

# Hold grub packages to prevent automatic updates
apt-mark hold \
    grub-pc \
    grub-pc-bin \
    grub2-common \
    grub-common


# ---------------------------------------------------------------
# IPv4를 포워딩하여 iptables가 브리지된 트래픽을 보게 하기
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 필요한 sysctl 파라미터를 설정하면, 재부팅 후에도 값이 유지된다.
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# sudo echo '1' | sudo tee /proc/sys/net/ipv4/ip_forward
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sysctl --system

sysctl net.ipv4.ip_forward
# ---------------------------------------------------------------



# SWAP 제거, # Turn off swap for kubeadm.
sudo swapoff -a
# sed -i '/swap/d' /etc/fstab
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

# Update system packages
apt-get update
apt-get dist-upgrade -y

# iptables 설정
SOURCE_FILE="/etc/sysctl.conf"
LINE_INPUT="net.bridge.bridge-nf-call-iptables = 1"
grep -qF "$LINE_INPUT" "$SOURCE_FILE"  || echo "$LINE_INPUT" | sudo tee -a "$SOURCE_FILE"

# 방화벽 등록
sudo ufw allow 179/tcp
sudo ufw allow 4789/udp
sudo ufw allow 5473/tcp
sudo ufw allow 443/tcp
sudo ufw allow 6443/tcp
sudo ufw allow 2379/tcp
sudo ufw allow 4149/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10255/tcp
sudo ufw allow 10256/tcp
sudo ufw allow 9099/tcp
sudo ufw allow 6443/tcp
# ---------------------------------------------------------------
