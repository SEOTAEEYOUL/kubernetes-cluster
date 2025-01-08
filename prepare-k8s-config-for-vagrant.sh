#!/bin/bash

# Prepare kubectl.
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# echo "This is admin"

# # required for setting up password less ssh between k8s VMs
# sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
# sudo service sshd restart

# # copying credentials to regular user - vagrant
# sudo --user=vagrant mkdir -p /home/vagrant/.kube
# apt-get install -y sshpass
# sshpass -p "vagrant" scp -o StrictHostKeyChecking=no vagrant@192.168.205.11:/home/vagrant/.kube/config /home/vagrant/.kube/config
# chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config
# export KUBECONFIG=/home/vagrant/.kube/config
# echo "export KUBECONFIG=/home/vagrant/.kube/config" /home/vagrant/.profile