# vagrant ssh

```
PS > vagrant status
Current machine states:

k8s-master                running (virtualbox)
k8s-worker-1              running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
PS > vagrant ssh k8s-master
vagrant@127.0.0.1's password: 
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-116-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Thu Jan  9 04:40:16 AM UTC 2025

  System load:  1.24               Processes:             162
  Usage of /:   12.1% of 30.34GB   Users logged in:       0
  Memory usage: 10%                IPv4 address for eth0: 10.0.2.15
  Swap usage:   0%


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento

Use of this system is acceptance of the OS vendor EULA and License Agreements.
vagrant@k8s-master:~$ ls
{}
vagrant@k8s-master:~$ kubectl get node
NAME           STATUS     ROLES           AGE   VERSION
k8s-master     NotReady   control-plane   57m   v1.32.0
k8s-worker-1   NotReady   <none>          47m   v1.32.0
PS > top
op - 05:47:19 up  1:07,  1 user,  load average: 8.22, 19.42, 24.34
Tasks: 162 total,   1 running, 161 sleeping,   0 stopped,   0 zombie
%Cpu(s): 16.6 us, 19.7 sy,  0.0 ni, 58.1 id,  0.7 wa,  0.0 hi,  4.9 si,  0.0 st
MiB Mem :   1963.8 total,    230.8 free,    613.4 used,   1119.5 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.   1167.1 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                        
  53197 root      20   0 1311760  67776  51960 S  62.5   3.4   0:01.88 kube-controller
  52022 root      20   0 1657548 342080  72648 S  11.3  17.0   0:56.80 kube-apiserver
  52121 root      20   0 2117892  93312  60868 S   8.3   4.6   0:34.93 kubelet
  52006 root      20   0   11.2g  64280  26104 S   7.3   3.2   0:31.34 etcd
  49744 root      20   0 2418944  61444  34976 S   2.3   3.1   0:21.47 containerd
    672 root      20   0  392620  11116   8928 S   1.7   0.6   0:00.66 udisksd
  51789 root      20   0 1238656  13068   9684 S   1.0   0.6   2:38.21 containerd-shim
  52619 root      20   0       0      0      0 I   1.0   0.0   0:01.22 kworker/0:1-events
      1 root      20   0  167748  12388   7472 S   0.7   0.6   0:10.64 systemd
PS > 
```