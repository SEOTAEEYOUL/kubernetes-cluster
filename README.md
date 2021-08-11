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

 * **[Vagrant 2.2.18+](https://www.vagrantup.com)**
 * **[Virtualbox 6.1.26+](https://www.virtualbox.org)**   
 * **[Discover Vagrant Boxes](https://app.vagrantup.com/boxes/search)**  

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
IMAGE_NAME=bento/ubuntu-18.04
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

## FAQ
### Why Bento ?
- Because HashiCorp (the makers of Vagrant) recommends the Bento Ubuntu.

### Why are the versions fixed?
- Because major changes over the packages may broke the setup.

### **"Call to WHvSetupPartition failed"** : 오류 발생시 조치할 사항?
- **Hyper-V** 를 비활성화 함
  - RUN > CMD > bcdedit /set hypervisorlaunchtype off, then reboot your machine.

### **Hyper-V** 재 활성화 하기
- RUN > CMD > bcdedit /set hypervisorlaunchtype auto, then reboot your machine.

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
> [varant up : vm 만들고 kubernetes cluster(1 master, 2 worker node) 생성](./vagrant-up.md)  
> [vargrant destroy -f : Vargrantfile 에서 생성된 VM 제거](./vagrant-destroy.md)