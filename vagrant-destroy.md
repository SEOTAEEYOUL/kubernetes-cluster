# vagrant destroy -f

## 출력 로그
```
PS > vagrant destroy -f
==> k8s-worker-2: Forcing shutdown of VM...
==> k8s-worker-2: Destroying VM and associated drives...
==> k8s-worker-1: Forcing shutdown of VM...
==> k8s-worker-1: Destroying VM and associated drives...
==> k8s-master: Forcing shutdown of VM...
==> k8s-master: Destroying VM and associated drives...
PS >
```

```
PS > vagrant status    
Current machine states:

k8s-master                poweroff (virtualbox)
k8s-worker-1              poweroff (virtualbox)

This environment represents multiple VMs. The VMs are all listed     
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
PS > vagrant destroy -f
==> k8s-worker-1: Destroying VM and associated drives...
==> k8s-master: Destroying VM and associated drives...
PS > vagrant status    
Current machine states:

k8s-master                not created (virtualbox)
k8s-worker-1              not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
PS > 
```