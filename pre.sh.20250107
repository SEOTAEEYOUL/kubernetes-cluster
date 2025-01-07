#!/bin/bash

# Update apt registry.
apt-get update

# get utility
apt-get install jq tmux -y

# Pass grub.
apt-mark hold package grub-pc grub-pc-bin grub2-common grub-common

# Upgrade packages and kernel.
apt-get dist-upgrade -y