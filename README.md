# Kubernetes cluster
A vagrant script for setting up a Kubernetes cluster using Kubeadm

## Components Version
### Image: bento/ubuntu-20.04
### Core
   * Docker Version: 20.10.7~3-0 :: recommaned
   * containerd v1.4.6
   * cri-o v1.21 (experimental: see CRI-O Note. Only on fedora, ubuntu and centos based OS)
   * Kubelet Version: 1.21.2-00
   * Kubectl Version: 1.21.2-00
   * Kubeadm Version: 1.21.2-00
### Network Plugin
   * cni-plugins v0.9.1
   * CNI: Flannel (Latest Version), calico v3.17.4

## Pre-requisites

 * **[Vagrant 2.1.4+](https://www.vagrantup.com)** - **Vagrant 2.2.18**
 * **[Virtualbox 5.2.18+](https://www.virtualbox.org)** -> **Virtualbox 6.1.26**  
 * **[Discover Vagrant Boxes](https://app.vagrantup.com/boxes/search)** -> **buntu/xenial64**
### Install the plugin for Vagrant to ability to use environment files.
```
vagrant plugin install vagrant-env
```
```
Installing the 'vagrant-env' plugin. This can take a few minutes...
Fetching dotenv-deployment-0.0.2.gem
Fetching dotenv-0.11.1.gem
Fetching vagrant-env-0.0.3.gem
Installed the plugin 'vagrant-env (0.0.3)'!
```

### Customize your own environment file.
- .env
```
IMAGE_NAME=bento/ubuntu-20.04
MEMORY_SIZE_IN_GB=2
CPU_COUNT=2
MASTER_NODE_COUNT=1
WORKER_NODE_COUNT=2
MASTER_NODE_IP_START=10.0.0.10
WORKER_NODE_IP_START=10.0.0.20
```


## How to Run

Execute the following vagrant command to start a new Kubernetes cluster, this will start one admin(bastion server), one master and two nodes:

```
vagrant up
```

You can also start invidual machines by vagrant up k8s-head, vagrant up k8s-node-1 and vagrant up k8s-node-2

If more than two nodes are required, you can edit the servers array in the Vagrantfile

```
servers = [
    {
        :name => "k8s-master",
        :type => "node",
        :box => "ubuntu/xenial64",
        :box_version => "v20210804.0.0",
        :eth1 => "192.128.0.13",
        :mem => "2048",
        :cpu => "2"
    }
]
 ```

As you can see above, you can also configure IP address, memory and CPU in the servers array. 

## Clean-up

Execute the following command to remove the virtual machines created for the Kubernetes cluster.
```
vagrant destroy -f
```

You can destroy individual machines by vagrant destroy k8s-node-1 -f 

## SSH 접속

SSH 접속, 가상 머신 상태 확인, 중지 및 삭제
```
$ vagrant ssh
```

## 가상머신의 상태 보기
vagrant status
```
vagrant status
Current machine states:

k8s-master                running (virtualbox)
k8s-node-1                not created (virtualbox)
k8s-node-2                not created (virtualbox)
k8s-admin                 not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

## Licensing

[Apache License, Version 2.0](http://opensource.org/licenses/Apache-2.0).  

## windows kubectl 설치
```
choco install kubernetes-cli
```
```
Chocolatey v0.10.15
Installing the following packages:
kubernetes-cli
By installing you accept licenses for the packages.
Progress: Downloading kubernetes-cli 1.22.0... 100%

kubernetes-cli v1.22.0 [Approved]
kubernetes-cli package files install completed. Performing other installation steps.
The package kubernetes-cli wants to run 'chocolateyInstall.ps1'.
Note: If you don't run this script, the installation will fail.
Note: To confirm automatically next time, use '-y' or consider:
choco feature enable -n allowGlobalConfirmation
Do you want to run the script?([Y]es/[A]ll - yes to all/[N]o/[P]rint): Y

Extracting 64-bit C:\ProgramData\chocolatey\lib\kubernetes-cli\tools\kubernetes-client-windows-amd64.tar.gz to C:\ProgramData\chocolatey\lib\kubernetes-cli\tools...
C:\ProgramData\chocolatey\lib\kubernetes-cli\tools
Extracting 64-bit C:\ProgramData\chocolatey\lib\kubernetes-cli\tools\kubernetes-client-windows-amd64.tar to C:\ProgramData\chocolatey\lib\kubernetes-cli\tools...
C:\ProgramData\chocolatey\lib\kubernetes-cli\tools
 ShimGen has successfully created a shim for kubectl-convert.exe
 ShimGen has successfully created a shim for kubectl.exe
 The install of kubernetes-cli was successful.
  Software installed to 'C:\ProgramData\chocolatey\lib\kubernetes-cli\tools'

Chocolatey installed 1/1 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).
```
```
kubectl version --client
Client Version: version.Info{Major:"1", Minor:"22", GitVersion:"v1.22.0", GitCommit:"c2b5237ccd9c0f1d600d3072634ca66cefdf272f", GitTreeState:"clean", BuildDate:"2021-08-04T18:03:20Z", GoVersion:"go1.16.6", Compiler:"gc", Platform:"windows/amd64"}
```

## 실행로그
```
vagrant plugin install vagrant-env
Installing the 'vagrant-env' plugin. This can take a few minutes...
Fetching dotenv-deployment-0.0.2.gem
Fetching dotenv-0.11.1.gem
Fetching vagrant-env-0.0.3.gem
Installed the plugin 'vagrant-env (0.0.3)'!
PS D:\workspace\kubernetes-cluster> vagrant up
Bringing machine 'm' up with 'virtualbox' provider...
Bringing machine 'n1' up with 'virtualbox' provider...
Bringing machine 'n2' up with 'virtualbox' provider...
==> m: Box 'bento/ubuntu-18.04' could not be found. Attempting to find and install...
    m: Box Provider: virtualbox
    m: Box Version: >= 0
==> m: Loading metadata for box 'bento/ubuntu-18.04'
    m: URL: https://vagrantcloud.com/bento/ubuntu-18.04
==> m: Adding box 'bento/ubuntu-18.04' (v202107.28.0) for provider: virtualbox
    m: Downloading: https://vagrantcloud.com/bento/boxes/ubuntu-18.04/versions/202107.28.0/providers/virtualbox.box
    m:
==> m: Successfully added box 'bento/ubuntu-18.04' (v202107.28.0) for 'virtualbox'!
==> m: Importing base box 'bento/ubuntu-18.04'...
==> m: Matching MAC address for NAT networking...
==> m: Checking if box 'bento/ubuntu-18.04' version '202107.28.0' is up to date...
==> m: Setting the name of the VM: kubernetes-cluster_m_1628583647975_38081
==> m: Clearing any previously set network interfaces...
==> m: Preparing network interfaces based on configuration...
    m: Adapter 1: nat
    m: Adapter 2: hostonly
==> m: Forwarding ports...
    m: 22 (guest) => 2222 (host) (adapter 1)
==> m: Running 'pre-boot' VM customizations...
==> m: Booting VM...
==> m: Waiting for machine to boot. This may take a few minutes...
    m: SSH address: 127.0.0.1:2222
    m: SSH username: vagrant
    m: SSH auth method: private key
    m: Warning: Connection reset. Retrying...
    m: Warning: Connection aborted. Retrying...
    m: Warning: Remote connection disconnect. Retrying...
    m:
    m: Vagrant insecure key detected. Vagrant will automatically replace
    m: this with a newly generated keypair for better security.
    m:
    m: Inserting generated public key within guest...
    m: Removing insecure key from the guest if it's present...
    m: Key inserted! Disconnecting and reconnecting using new SSH key...
==> m: Machine booted and ready!
==> m: Checking for guest additions in VM...
==> m: Setting hostname...
==> m: Configuring and enabling network interfaces...
==> m: Mounting shared folders...
    m: /vagrant => D:/workspace/kubernetes-cluster
==> m: Running provisioner: shell...
    m: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210810-2192-16inhxr.sh
    m: Hit:1 http://archive.ubuntu.com/ubuntu bionic InRelease
    m: Get:2 http://security.ubuntu.com/ubuntu bionic-security InRelease [88.7 kB]
    m: Get:3 http://archive.ubuntu.com/ubuntu bionic-updates InRelease [88.7 kB]
    m: Get:4 http://archive.ubuntu.com/ubuntu bionic-backports InRelease [74.6 kB]
    m: Get:5 http://security.ubuntu.com/ubuntu bionic-security/main i386 Packages [1,022 kB]
    m: Get:6 http://archive.ubuntu.com/ubuntu bionic-updates/main i386 Packages [1,327 kB]
    m: Get:7 http://security.ubuntu.com/ubuntu bionic-security/main amd64 Packages [1,818 kB]
    m: Get:8 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 Packages [2,165 kB]
    m: Get:9 http://security.ubuntu.com/ubuntu bionic-security/main Translation-en [335 kB]
    m: Get:10 http://security.ubuntu.com/ubuntu bionic-security/restricted amd64 Packages [394 kB]
    m: Get:11 http://security.ubuntu.com/ubuntu bionic-security/restricted Translation-en [53.0 kB]
    m: Get:12 http://security.ubuntu.com/ubuntu bionic-security/universe amd64 Packages [1,132 kB]
    m: Get:13 http://archive.ubuntu.com/ubuntu bionic-updates/main Translation-en [427 kB]
    m: Get:14 http://security.ubuntu.com/ubuntu bionic-security/universe i386 Packages [984 kB]
    m: Get:15 http://archive.ubuntu.com/ubuntu bionic-updates/restricted amd64 Packages [418 kB]
    m: Get:16 http://archive.ubuntu.com/ubuntu bionic-updates/restricted Translation-en [56.8 kB]
    m: Get:17 http://archive.ubuntu.com/ubuntu bionic-updates/universe amd64 Packages [1,744 kB]
    m: Get:18 http://security.ubuntu.com/ubuntu bionic-security/universe Translation-en [257 kB]
    m: Get:19 http://archive.ubuntu.com/ubuntu bionic-updates/universe i386 Packages [1,571 kB]
    m: Get:20 http://archive.ubuntu.com/ubuntu bionic-updates/universe Translation-en [373 kB]
    m: Get:21 http://archive.ubuntu.com/ubuntu bionic-updates/multiverse i386 Packages [13.0 kB]
    m: Get:22 http://archive.ubuntu.com/ubuntu bionic-updates/multiverse amd64 Packages [30.9 kB]
    m: Get:23 http://archive.ubuntu.com/ubuntu bionic-updates/multiverse Translation-en [6,988 B]
    m: Fetched 14.4 MB in 57s (250 kB/s)
    m: Reading package lists...
    m: grub-pc set on hold.
    m: grub-pc-bin set on hold.
    m: grub2-common set on hold.
    m: grub-common set on hold.
    m: E: Unable to locate package package
    m: Reading package lists...
    m: Building dependency tree...
    m: Reading state information...
    m: Calculating upgrade...
    m: The following NEW packages will be installed:
    m:   linux-image-4.15.0-153-generic linux-modules-4.15.0-153-generic
    m:   linux-modules-extra-4.15.0-153-generic
    m: The following packages will be upgraded:
    m:   linux-image-generic sosreport wireless-regdb
    m: 3 upgraded, 3 newly installed, 0 to remove and 0 not upgraded.
    m: 1 standard security update
    m: Need to get 55.5 MB of archives.
    m: After this operation, 260 MB of additional disk space will be used.
    m: Get:1 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 linux-modules-4.15.0-153-generic amd64 4.15.0-153.160 [13.4 MB]
    m: Get:2 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 linux-image-4.15.0-153-generic amd64 4.15.0-153.160 [8,091 kB]
    m: Get:3 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 linux-modules-extra-4.15.0-153-generic amd64 4.15.0-153.160 [33.7 MB]
    m: Get:4 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 linux-image-generic amd64 4.15.0.153.142 [2,548 B]
    m: Get:5 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 sosreport amd64 4.1-1ubuntu0.18.04.3 [245 kB]
    m: Get:6 http://archive.ubuntu.com/ubuntu bionic-updates/main amd64 wireless-regdb all 2021.07.14-0ubuntu1~18.04.1 [10.1 kB]
    m: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    m: Fetched 55.5 MB in 6min 45s (137 kB/s)
    m: Selecting previously unselected package linux-modules-4.15.0-153-generic.
(Reading database ... 39787 files and directories currently installed.)
    m: Preparing to unpack .../0-linux-modules-4.15.0-153-generic_4.15.0-153.160_amd64.deb ...
    m: Unpacking linux-modules-4.15.0-153-generic (4.15.0-153.160) ...
    m: Selecting previously unselected package linux-image-4.15.0-153-generic.
    m: Preparing to unpack .../1-linux-image-4.15.0-153-generic_4.15.0-153.160_amd64.deb ...
    m: Unpacking linux-image-4.15.0-153-generic (4.15.0-153.160) ...
    m: Selecting previously unselected package linux-modules-extra-4.15.0-153-generic.
    m: Preparing to unpack .../2-linux-modules-extra-4.15.0-153-generic_4.15.0-153.160_amd64.deb ...
    m: Unpacking linux-modules-extra-4.15.0-153-generic (4.15.0-153.160) ...
    m: Preparing to unpack .../3-linux-image-generic_4.15.0.153.142_amd64.deb ...
    m: Unpacking linux-image-generic (4.15.0.153.142) over (4.15.0.151.139) ...
    m: Preparing to unpack .../4-sosreport_4.1-1ubuntu0.18.04.3_amd64.deb ...
    m: Unpacking sosreport (4.1-1ubuntu0.18.04.3) over (4.1-1ubuntu0.18.04.2) ...
    m: Preparing to unpack .../5-wireless-regdb_2021.07.14-0ubuntu1~18.04.1_all.deb ...
    m: Unpacking wireless-regdb (2021.07.14-0ubuntu1~18.04.1) over (2020.11.20-0ubuntu1~18.04.1) ...
    m: Setting up wireless-regdb (2021.07.14-0ubuntu1~18.04.1) ...
    m: Setting up linux-modules-4.15.0-153-generic (4.15.0-153.160) ...
    m: Setting up sosreport (4.1-1ubuntu0.18.04.3) ...
    m: Setting up linux-image-4.15.0-153-generic (4.15.0-153.160) ...
    m: I: /vmlinuz is now a symlink to boot/vmlinuz-4.15.0-153-generic
    m: I: /initrd.img is now a symlink to boot/initrd.img-4.15.0-153-generic
    m: Setting up linux-modules-extra-4.15.0-153-generic (4.15.0-153.160) ...
    m: Setting up linux-image-generic (4.15.0.153.142) ...
    m: Processing triggers for man-db (2.8.3-2ubuntu0.1) ...
    m: Processing triggers for man-db (2.8.3-2ubuntu0.1) ...
    m: Processing triggers for linux-image-4.15.0-153-generic (4.15.0-153.160) ...
    m: /etc/kernel/postinst.d/dkms:
    m: dkms: WARNING: Linux headers are missing, which may explain the above failures.
    m:       please install the linux-headers-4.15.0-153-generic package to fix this.
    m: /etc/kernel/postinst.d/initramfs-tools:
    m: update-initramfs: Generating /boot/initrd.img-4.15.0-153-generic
    m: /etc/kernel/postinst.d/zz-update-grub:
    m: Sourcing file `/etc/default/grub'
    m: Generating grub configuration file ...
    m: Found linux image: /boot/vmlinuz-4.15.0-153-generic
    m: Found initrd image: /boot/initrd.img-4.15.0-153-generic
    m: Found linux image: /boot/vmlinuz-4.15.0-151-generic
    m: Found initrd image: /boot/initrd.img-4.15.0-151-generic
    m: done
==> m: Running provisioner: shell...
    m: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210810-2192-l9ahaf.sh
    m: Reading package lists...
    m: Building dependency tree...
    m: Reading state information...
    m: ca-certificates is already the newest version (20210119~18.04.1).
    m: curl is already the newest version (7.58.0-2ubuntu3.14).
    m: software-properties-common is already the newest version (0.96.24.32.14).
    m: The following NEW packages will be installed:
    m:   apt-transport-https gnupg-agent
    m: 0 upgraded, 2 newly installed, 0 to remove and 0 not upgraded.
    m: Need to get 9,212 B of archives.
    m: After this operation, 197 kB of additional disk space will be used.
    m: Get:1 http://archive.ubuntu.com/ubuntu bionic-updates/universe amd64 apt-transport-https all 1.6.14 [4,348 B]
    m: Get:2 http://archive.ubuntu.com/ubuntu bionic-updates/universe amd64 gnupg-agent all 2.2.4-1ubuntu1.4 [4,864 B]
    m: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    m: Fetched 9,212 B in 1s (8,867 B/s)
    m: Selecting previously unselected package apt-transport-https.
(Reading database ... 46030 files and directories currently installed.)
    m: Preparing to unpack .../apt-transport-https_1.6.14_all.deb ...
    m: Unpacking apt-transport-https (1.6.14) ...
    m: Selecting previously unselected package gnupg-agent.
    m: Preparing to unpack .../gnupg-agent_2.2.4-1ubuntu1.4_all.deb ...
    m: Unpacking gnupg-agent (2.2.4-1ubuntu1.4) ...
    m: Setting up apt-transport-https (1.6.14) ...
    m: Setting up gnupg-agent (2.2.4-1ubuntu1.4) ...
    m: Get:1 https://download.docker.com/linux/ubuntu bionic InRelease [64.4 kB]
    m: Get:2 https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages [19.8 kB]
    m: Hit:3 http://archive.ubuntu.com/ubuntu bionic InRelease
    m: Hit:4 http://security.ubuntu.com/ubuntu bionic-security InRelease
    m: Hit:5 http://archive.ubuntu.com/ubuntu bionic-updates InRelease
    m: Hit:6 http://archive.ubuntu.com/ubuntu bionic-backports InRelease
    m: Fetched 84.3 kB in 1s (68.2 kB/s)
    m: Reading package lists...
    m: Reading package lists...
    m: Building dependency tree...
    m: Reading state information...
    m: The following additional packages will be installed:
    m:   docker-ce-rootless-extras docker-scan-plugin libltdl7 pigz
    m: Suggested packages:
    m:   aufs-tools cgroupfs-mount | cgroup-lite
    m: Recommended packages:
    m:   slirp4netns
    m: The following NEW packages will be installed:
    m:   containerd.io docker-ce docker-ce-cli docker-ce-rootless-extras
    m:   docker-scan-plugin libltdl7 pigz
    m: 0 upgraded, 7 newly installed, 0 to remove and 0 not upgraded.
    m: Need to get 106 MB of archives.
    m: After this operation, 461 MB of additional disk space will be used.
    m: Get:1 https://download.docker.com/linux/ubuntu bionic/stable amd64 containerd.io amd64 1.4.6-1 [28.3 MB]
    m: Get:2 http://archive.ubuntu.com/ubuntu bionic/universe amd64 pigz amd64 2.4-1 [57.4 kB]
    m: Get:3 https://download.docker.com/linux/ubuntu bionic/stable amd64 docker-ce-cli amd64 5:20.10.7~3-0~ubuntu-bionic [41.4 MB]
    m: Get:4 http://archive.ubuntu.com/ubuntu bionic/main amd64 libltdl7 amd64 2.4.6-2 [38.8 kB]
    m: Get:5 https://download.docker.com/linux/ubuntu bionic/stable amd64 docker-ce amd64 5:20.10.7~3-0~ubuntu-bionic [24.8 MB]
    m: Get:6 https://download.docker.com/linux/ubuntu bionic/stable amd64 docker-ce-rootless-extras amd64 5:20.10.8~3-0~ubuntu-bionic [7,911 kB]
    m: Get:7 https://download.docker.com/linux/ubuntu bionic/stable amd64 docker-scan-plugin amd64 0.8.0~ubuntu-bionic [3,888 kB]
    m: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    m: Fetched 106 MB in 9s (11.7 MB/s)
    m: Selecting previously unselected package pigz.
(Reading database ... 46038 files and directories currently installed.)
    m: Preparing to unpack .../0-pigz_2.4-1_amd64.deb ...
    m: Unpacking pigz (2.4-1) ...
    m: Selecting previously unselected package containerd.io.
    m: Preparing to unpack .../1-containerd.io_1.4.6-1_amd64.deb ...
    m: Unpacking containerd.io (1.4.6-1) ...
    m: Selecting previously unselected package docker-ce-cli.
    m: Preparing to unpack .../2-docker-ce-cli_5%3a20.10.7~3-0~ubuntu-bionic_amd64.deb ...
    m: Unpacking docker-ce-cli (5:20.10.7~3-0~ubuntu-bionic) ...
    m: Selecting previously unselected package docker-ce.
    m: Preparing to unpack .../3-docker-ce_5%3a20.10.7~3-0~ubuntu-bionic_amd64.deb ...
    m: Unpacking docker-ce (5:20.10.7~3-0~ubuntu-bionic) ...
    m: Selecting previously unselected package docker-ce-rootless-extras.
    m: Preparing to unpack .../4-docker-ce-rootless-extras_5%3a20.10.8~3-0~ubuntu-bionic_amd64.deb ...
    m: Unpacking docker-ce-rootless-extras (5:20.10.8~3-0~ubuntu-bionic) ...
    m: Selecting previously unselected package docker-scan-plugin.
    m: Preparing to unpack .../5-docker-scan-plugin_0.8.0~ubuntu-bionic_amd64.deb ...
    m: Unpacking docker-scan-plugin (0.8.0~ubuntu-bionic) ...
    m: Selecting previously unselected package libltdl7:amd64.
    m: Preparing to unpack .../6-libltdl7_2.4.6-2_amd64.deb ...
    m: Unpacking libltdl7:amd64 (2.4.6-2) ...
    m: Setting up containerd.io (1.4.6-1) ...
    m: Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /lib/systemd/system/containerd.service.
    m: Setting up docker-ce-rootless-extras (5:20.10.8~3-0~ubuntu-bionic) ...
    m: Setting up docker-scan-plugin (0.8.0~ubuntu-bionic) ...
    m: Setting up libltdl7:amd64 (2.4.6-2) ...
    m: Setting up docker-ce-cli (5:20.10.7~3-0~ubuntu-bionic) ...
    m: Setting up pigz (2.4-1) ...
    m: Setting up docker-ce (5:20.10.7~3-0~ubuntu-bionic) ...
    m: Created symlink /etc/systemd/system/multi-user.target.wants/docker.service → /lib/systemd/system/docker.service.
    m: Created symlink /etc/systemd/system/sockets.target.wants/docker.socket → /lib/systemd/system/docker.socket.
    m: Processing triggers for libc-bin (2.27-3ubuntu1.4) ...
    m: Processing triggers for systemd (237-3ubuntu10.50) ...
    m: Processing triggers for man-db (2.8.3-2ubuntu0.1) ...
    m: Processing triggers for ureadahead (0.100.0-21) ...
    m: Synchronizing state of docker.service with SysV service script with /lib/systemd/systemd-sysv-install.
    m: Executing: /lib/systemd/systemd-sysv-install enable docker
    m: docker-ce set on hold.
==> m: Running provisioner: shell...
    m: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210810-2192-t57jws.sh
    m: Reading package lists...
    m: Building dependency tree...
    m: Reading state information...
    m: curl is already the newest version (7.58.0-2ubuntu3.14).
    m: apt-transport-https is already the newest version (1.6.14).
    m: 0 upgraded, 0 newly installed, 0 to remove and 3 not upgraded.
    m: deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main
    m: Hit:1 https://download.docker.com/linux/ubuntu bionic InRelease
    m: Hit:2 http://security.ubuntu.com/ubuntu bionic-security InRelease
    m: Get:3 https://packages.cloud.google.com/apt kubernetes-xenial InRelease [9,383 B]
    m: Hit:4 http://archive.ubuntu.com/ubuntu bionic InRelease
    m: Get:5 https://packages.cloud.google.com/apt kubernetes-xenial/main amd64 Packages [48.5 kB]
    m: Hit:6 http://archive.ubuntu.com/ubuntu bionic-updates InRelease
    m: Hit:7 http://archive.ubuntu.com/ubuntu bionic-backports InRelease
    m: Fetched 57.9 kB in 2s (33.5 kB/s)
    m: Reading package lists...
    m: Reading package lists...
    m: Building dependency tree...
    m: Reading state information...
    m: The following additional packages will be installed:
    m:   conntrack cri-tools kubernetes-cni socat
    m: The following NEW packages will be installed:
    m:   conntrack cri-tools kubeadm kubectl kubelet kubernetes-cni socat
    m: 0 upgraded, 7 newly installed, 0 to remove and 3 not upgraded.
    m: Need to get 70.5 MB of archives.
    m: After this operation, 309 MB of additional disk space will be used.
    m: Get:3 http://archive.ubuntu.com/ubuntu bionic/main amd64 conntrack amd64 1:1.4.4+snapshot20161117-6ubuntu2 [30.6 kB]
    m: Get:1 https://packages.cloud.google.com/apt kubernetes-xenial/main amd64 cri-tools amd64 1.13.0-01 [8,775 kB]
    m: Get:7 http://archive.ubuntu.com/ubuntu bionic/main amd64 socat amd64 1.7.3.2-2ubuntu2 [342 kB]
    m: Get:2 https://packages.cloud.google.com/apt kubernetes-xenial/main amd64 kubernetes-cni amd64 0.8.7-00 [25.0 MB]
    m: Get:4 https://packages.cloud.google.com/apt kubernetes-xenial/main amd64 kubelet amd64 1.21.2-00 [18.8 MB]
    m: Get:5 https://packages.cloud.google.com/apt kubernetes-xenial/main amd64 kubectl amd64 1.21.2-00 [8,966 kB]
    m: Get:6 https://packages.cloud.google.com/apt kubernetes-xenial/main amd64 kubeadm amd64 1.21.2-00 [8,547 kB]
    m: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    m: Fetched 70.5 MB in 11s (6,240 kB/s)
    m: Selecting previously unselected package conntrack.
(Reading database ... 46291 files and directories currently installed.)
    m: Preparing to unpack .../0-conntrack_1%3a1.4.4+snapshot20161117-6ubuntu2_amd64.deb ...
    m: Unpacking conntrack (1:1.4.4+snapshot20161117-6ubuntu2) ...
    m: Selecting previously unselected package cri-tools.
    m: Preparing to unpack .../1-cri-tools_1.13.0-01_amd64.deb ...
    m: Unpacking cri-tools (1.13.0-01) ...
    m: Selecting previously unselected package kubernetes-cni.
    m: Preparing to unpack .../2-kubernetes-cni_0.8.7-00_amd64.deb ...
    m: Unpacking kubernetes-cni (0.8.7-00) ...
    m: Selecting previously unselected package socat.
    m: Preparing to unpack .../3-socat_1.7.3.2-2ubuntu2_amd64.deb ...
    m: Unpacking socat (1.7.3.2-2ubuntu2) ...
    m: Selecting previously unselected package kubelet.
    m: Preparing to unpack .../4-kubelet_1.21.2-00_amd64.deb ...
    m: Unpacking kubelet (1.21.2-00) ...
    m: Selecting previously unselected package kubectl.
    m: Preparing to unpack .../5-kubectl_1.21.2-00_amd64.deb ...
    m: Unpacking kubectl (1.21.2-00) ...
    m: Selecting previously unselected package kubeadm.
    m: Preparing to unpack .../6-kubeadm_1.21.2-00_amd64.deb ...
    m: Unpacking kubeadm (1.21.2-00) ...
    m: Setting up conntrack (1:1.4.4+snapshot20161117-6ubuntu2) ...
    m: Setting up kubernetes-cni (0.8.7-00) ...
    m: Setting up cri-tools (1.13.0-01) ...
    m: Setting up socat (1.7.3.2-2ubuntu2) ...
    m: Setting up kubelet (1.21.2-00) ...
    m: Created symlink /etc/systemd/system/multi-user.target.wants/kubelet.service → /lib/systemd/system/kubelet.service.
    m: Setting up kubectl (1.21.2-00) ...
    m: Setting up kubeadm (1.21.2-00) ...
    m: Processing triggers for man-db (2.8.3-2ubuntu0.1) ...
    m: kubelet set on hold.
    m: kubeadm set on hold.
    m: kubectl set on hold.
==> m: Running provisioner: shell...
    m: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210810-2192-1vuxvz6.sh
==> m: Running provisioner: shell...
    m: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210810-2192-oiippx.sh
    m: I0810 08:32:03.765461   24757 version.go:254] remote version is much newer: v1.22.0; falling back to: stable-1.21
    m: [init] Using Kubernetes version: v1.21.3
    m: [preflight] Running pre-flight checks
    m:  [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
    m: [preflight] Pulling images required for setting up a Kubernetes cluster
    m: [preflight] This might take a minute or two, depending on the speed of your internet connection
    m: [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
    m: [certs] Using certificateDir folder "/etc/kubernetes/pki"
    m: [certs] Generating "ca" certificate and key
    m: [certs] Generating "apiserver" certificate and key
    m: [certs] apiserver serving cert is signed for DNS names [kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local m] and IPs [10.96.0.1 10.0.0.101]
    m: [certs] Generating "apiserver-kubelet-client" certificate and key
    m: [certs] Generating "front-proxy-ca" certificate and key
    m: [certs] Generating "front-proxy-client" certificate and key
    m: [certs] Generating "etcd/ca" certificate and key
    m: [certs] Generating "etcd/server" certificate and key
    m: [certs] etcd/server serving cert is signed for DNS names [localhost m] and IPs [10.0.0.101 127.0.0.1 ::1]
    m: [certs] Generating "etcd/peer" certificate and key
    m: [certs] etcd/peer serving cert is signed for DNS names [localhost m] and IPs [10.0.0.101 127.0.0.1 ::1]
    m: [certs] Generating "etcd/healthcheck-client" certificate and key
    m: [certs] Generating "apiserver-etcd-client" certificate and key
    m: [certs] Generating "sa" key and public key
    m: [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
    m: [kubeconfig] Writing "admin.conf" kubeconfig file
    m: [kubeconfig] Writing "kubelet.conf" kubeconfig file
    m: [kubeconfig] Writing "controller-manager.conf" kubeconfig file
    m: [kubeconfig] Writing "scheduler.conf" kubeconfig file
    m: [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    m: [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    m: [kubelet-start] Starting the kubelet
    m: [control-plane] Using manifest folder "/etc/kubernetes/manifests"
    m: [control-plane] Creating static Pod manifest for "kube-apiserver"
    m: [control-plane] Creating static Pod manifest for "kube-controller-manager"
    m: [control-plane] Creating static Pod manifest for "kube-scheduler"
    m: [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
    m: [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
    m: [apiclient] All control plane components are healthy after 18.024935 seconds
    m: [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
    m: [kubelet] Creating a ConfigMap "kubelet-config-1.21" in namespace kube-system with the configuration for the kubelets in the cluster
    m: [upload-certs] Skipping phase. Please see --upload-certs
    m: [mark-control-plane] Marking the node m as control-plane by adding the labels: [node-role.kubernetes.io/master(deprecated) node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
    m: [mark-control-plane] Marking the node m as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
    m: [bootstrap-token] Using token: gf6yz1.a7lw41wyh27fldnj
    m: [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
    m: [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
    m: [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
    m: [bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
    m: [bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
    m: [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
    m: [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
    m: [addons] Applied essential addon: CoreDNS
    m: [addons] Applied essential addon: kube-proxy
    m:
    m: Your Kubernetes control-plane has initialized successfully!
    m:
    m: To start using your cluster, you need to run the following as a regular user:
    m:
    m:   mkdir -p $HOME/.kube
    m:   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    m:   sudo chown $(id -u):$(id -g) $HOME/.kube/config
    m:
    m: Alternatively, if you are the root user, you can run:
    m:
    m:   export KUBECONFIG=/etc/kubernetes/admin.conf
    m:
    m: You should now deploy a pod network to the cluster.
    m: Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    m:   https://kubernetes.io/docs/concepts/cluster-administration/addons/
    m:
    m: Then you can join any number of worker nodes by running the following on each as root:
    m:
    m: kubeadm join 10.0.0.101:6443 --token gf6yz1.a7lw41wyh27fldnj \
    m:  --discovery-token-ca-cert-hash sha256:c9429c59f9e29541886ec432fb7db05a340e5c390e7e14a416e37707121f5c3a
==> m: Running provisioner: shell...
    m: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210810-2192-12cqm5l.sh
==> m: Running provisioner: shell...
    m: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210810-2192-djruo7.sh
==> m: Running provisioner: shell...
    m: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210810-2192-1bk8za2.sh
    m: Warning: policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
    m: podsecuritypolicy.policy/psp.flannel.unprivileged created
    m: clusterrole.rbac.authorization.k8s.io/flannel created
    m: clusterrolebinding.rbac.authorization.k8s.io/flannel created
    m: serviceaccount/flannel created
    m: configmap/kube-flannel-cfg created
    m: daemonset.apps/kube-flannel-ds created
==> n1: Box 'bento/ubuntu-18.04' could not be found. Attempting to find and install...
    n1: Box Provider: virtualbox
    n1: Box Version: >= 0
==> n1: Loading metadata for box 'bento/ubuntu-18.04'
    n1: URL: https://vagrantcloud.com/bento/ubuntu-18.04
==> n1: Adding box 'bento/ubuntu-18.04' (v202107.28.0) for provider: virtualbox
==> n1: Importing base box 'bento/ubuntu-18.04'...

```