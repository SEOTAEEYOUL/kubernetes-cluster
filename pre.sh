#!/bin/bash
set -e

# Update apt registry.
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

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

# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# Update system packages
apt-get update
apt-get dist-upgrade -y

# Load kernel modules required for Kubernetes
cat > /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Update kernel parameters for Kubernetes
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system