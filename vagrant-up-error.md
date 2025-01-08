# vargrant up -> Error

- VirtualBox 7.1.4 에서 오류 발생
- plugin 이 7.0.18 용

## Memory 1 GB 일 경우 오류
```
╭─ pwsh     kubernetes-cluster    master ≡  ?2 ~9 -1   36s 180ms⠀                                         default@ap-northeast-2  arn:aws:eks:ap-northeast-2:143719223348:cluster/sksh-argos-p-eks-ui-01    97    8,17:26 
╰─ vagrant up        
Bringing machine 'k8s-master' up with 'virtualbox' provider...
Bringing machine 'k8s-worker-1' up with 'virtualbox' provider...
Bringing machine 'k8s-worker-2' up with 'virtualbox' provider...
==> k8s-master: Importing base box 'bento/ubuntu-22.04'...
==> k8s-master: Matching MAC address for NAT networking...
==> k8s-master: Checking if box 'bento/ubuntu-22.04' version '202407.23.0' is up to date...
==> k8s-master: Setting the name of the VM: kubernetes-cluster_k8s-master_1736324895869_82832
==> k8s-master: Fixed port collision for 22 => 2222. Now on port 2200.
==> k8s-master: Clearing any previously set network interfaces...
==> k8s-master: Preparing network interfaces based on configuration...
    k8s-master: Adapter 1: nat
    k8s-master: Adapter 2: intnet
==> k8s-master: Forwarding ports...
    k8s-master: 22 (guest) => 2200 (host) (adapter 1)
==> k8s-master: Running 'pre-boot' VM customizations...
==> k8s-master: Booting VM...
==> k8s-master: Waiting for machine to boot. This may take a few minutes...
    k8s-master: SSH address: 127.0.0.1:2200
    k8s-master: SSH username: vagrant
    k8s-master: SSH auth method: private key
    k8s-master: Warning: Connection reset. Retrying...
    k8s-master: Warning: Connection aborted. Retrying...
    k8s-master: Warning: Remote connection disconnect. Retrying...
    k8s-master: 
    k8s-master: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-master: this with a newly generated keypair for better security.
    k8s-master: 
    k8s-master: Inserting generated public key within guest...
==> k8s-master: Machine booted and ready!
[k8s-master] GuestAdditions seems to be installed (7.0.18) correctly, but not running.
update-initramfs: Generating /boot/initrd.img-5.15.0-116-generic
VirtualBox Guest Additions: Starting.
VirtualBox Guest Additions: Setting up modules
VirtualBox Guest Additions: Building the VirtualBox Guest Additions kernel 
modules.  This may take a while.
VirtualBox Guest Additions: To build modules for other installed kernels, run
VirtualBox Guest Additions:   /sbin/rcvboxadd quicksetup <version>
VirtualBox Guest Additions: or
VirtualBox Guest Additions:   /sbin/rcvboxadd quicksetup all
VirtualBox Guest Additions: Kernel headers not found for target kernel
5.15.0-116-generic. Please install them and execute
  /sbin/rcvboxadd setup
Restarting VM to apply changes...
==> k8s-master: Attempting graceful shutdown of VM...
==> k8s-master: Booting VM...
==> k8s-master: Waiting for machine to boot. This may take a few minutes...
==> k8s-master: Machine booted and ready!
==> k8s-master: Checking for guest additions in VM...
==> k8s-master: Setting hostname...
==> k8s-master: Configuring and enabling network interfaces...
==> k8s-master: Mounting shared folders...
    k8s-master: D:/workspace/kubernetes-cluster => /vagrant
==> k8s-master: Running provisioner: shell...
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-35872-h8apcc.sh
    k8s-master: nc: connect to 127.0.0.1 port 6443 (tcp) failed: Connection refused
    k8s-master: Hit:1 http://us.archive.ubuntu.com/ubuntu jammy InRelease
    k8s-master: Get:2 http://security.ubuntu.com/ubuntu jammy-security InRelease [129 kB]
    k8s-master: Get:3 http://us.archive.ubuntu.com/ubuntu jammy-updates InRelease [128 kB]
    k8s-master: Get:4 http://us.archive.ubuntu.com/ubuntu jammy-backports InRelease [127 kB]
    k8s-master: Get:5 http://security.ubuntu.com/ubuntu jammy-security/main amd64 Packages [2,036 kB]
    k8s-master: Get:6 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages [2,271 kB]
    k8s-master: Get:7 http://security.ubuntu.com/ubuntu jammy-security/main Translation-en [321 kB]
    k8s-master: Get:8 http://security.ubuntu.com/ubuntu jammy-security/restricted amd64 Packages [2,761 kB]
    k8s-master: Get:9 http://security.ubuntu.com/ubuntu jammy-security/restricted Translation-en [482 kB]
    k8s-master: Get:10 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 Packages [958 kB]
    k8s-master: Get:11 http://security.ubuntu.com/ubuntu jammy-security/universe Translation-en [204 kB]
    k8s-master: Get:12 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 Packages [37.6 kB]
    k8s-master: Get:13 http://security.ubuntu.com/ubuntu jammy-security/multiverse Translation-en [8,260 B]
    k8s-master: Get:14 http://us.archive.ubuntu.com/ubuntu jammy-updates/main Translation-en [382 kB]
    k8s-master: Get:15 http://us.archive.ubuntu.com/ubuntu jammy-updates/restricted amd64 Packages [2,867 kB]
    k8s-master: Get:16 http://us.archive.ubuntu.com/ubuntu jammy-updates/restricted Translation-en [500 kB]
    k8s-master: Get:17 http://us.archive.ubuntu.com/ubuntu jammy-updates/universe amd64 Packages [1,181 kB]
    k8s-master: Get:18 http://us.archive.ubuntu.com/ubuntu jammy-updates/universe Translation-en [288 kB]
    k8s-master: Get:19 http://us.archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 Packages [44.5 kB]
    k8s-master: Get:20 http://us.archive.ubuntu.com/ubuntu jammy-updates/multiverse Translation-en [11.5 kB]
    k8s-master: Get:21 http://us.archive.ubuntu.com/ubuntu jammy-backports/main amd64 Packages [67.7 kB]
    k8s-master: Get:22 http://us.archive.ubuntu.com/ubuntu jammy-backports/main Translation-en [11.1 kB]
    k8s-master: Get:23 http://us.archive.ubuntu.com/ubuntu jammy-backports/universe amd64 Packages [28.9 kB]
    k8s-master: Get:24 http://us.archive.ubuntu.com/ubuntu jammy-backports/universe Translation-en [16.5 kB]
    k8s-master: Fetched 14.9 MB in 7s (2,010 kB/s)
    k8s-master: Reading package lists...
    k8s-master: Reading package lists...
    k8s-master: Building dependency tree...
    k8s-master: Reading state information...
    k8s-master: The following additional packages will be installed:
    k8s-master:   libcurl4
    k8s-master: The following NEW packages will be installed:
    k8s-master:   apt-transport-https
    k8s-master: The following packages will be upgraded:
    k8s-master:   ca-certificates curl libcurl4
    k8s-master: 3 upgraded, 1 newly installed, 0 to remove and 77 not upgraded.
    k8s-master: Need to get 647 kB of archives.
    k8s-master: After this operation, 181 kB of additional disk space will be used.
    k8s-master: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 ca-certificates all 20240203~22.04.1 [162 kB]
    k8s-master: Get:2 http://us.archive.ubuntu.com/ubuntu jammy-updates/universe amd64 apt-transport-https all 2.4.13 [1,510 B]
    k8s-master: Get:3 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 curl amd64 7.81.0-1ubuntu1.20 [194 kB]
    k8s-master: Get:4 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libcurl4 amd64 7.81.0-1ubuntu1.20 [289 kB]
    k8s-master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-master: Fetched 647 kB in 2s (301 kB/s)
(Reading database ... 44902 files and directories currently installed.)
    k8s-master: Preparing to unpack .../ca-certificates_20240203~22.04.1_all.deb ...
    k8s-master: Unpacking ca-certificates (20240203~22.04.1) over (20230311ubuntu0.22.04.1) ...
    k8s-master: Selecting previously unselected package apt-transport-https.
    k8s-master: Preparing to unpack .../apt-transport-https_2.4.13_all.deb ...
    k8s-master: Unpacking apt-transport-https (2.4.13) ...
    k8s-master: Preparing to unpack .../curl_7.81.0-1ubuntu1.20_amd64.deb ...
    k8s-master: Unpacking curl (7.81.0-1ubuntu1.20) over (7.81.0-1ubuntu1.16) ...
    k8s-master: Preparing to unpack .../libcurl4_7.81.0-1ubuntu1.20_amd64.deb ...
    k8s-master: Unpacking libcurl4:amd64 (7.81.0-1ubuntu1.20) over (7.81.0-1ubuntu1.16) ...
    k8s-master: Setting up apt-transport-https (2.4.13) ...
    k8s-master: Setting up ca-certificates (20240203~22.04.1) ...
    k8s-master: Updating certificates in /etc/ssl/certs...
    k8s-master: rehash: warning: skipping ca-certificates.crt,it does not contain exactly one certificate or CRL
    k8s-master: 14 added, 5 removed; done.
    k8s-master: Setting up libcurl4:amd64 (7.81.0-1ubuntu1.20) ...
    k8s-master: Setting up curl (7.81.0-1ubuntu1.20) ...
    k8s-master: Processing triggers for man-db (2.10.2-1) ...
    k8s-master: Processing triggers for libc-bin (2.35-0ubuntu3.8) ...
    k8s-master: Processing triggers for ca-certificates (20240203~22.04.1) ...
    k8s-master: Updating certificates in /etc/ssl/certs...
    k8s-master: 0 added, 0 removed; done.
    k8s-master: Running hooks in /etc/ca-certificates/update.d...
    k8s-master: done.
    k8s-master: 
    k8s-master: Running kernel seems to be up-to-date.
    k8s-master:
    k8s-master: No services need to be restarted.
    k8s-master:
    k8s-master: No containers need to be restarted.
    k8s-master:
    k8s-master: No user sessions are running outdated binaries.
    k8s-master:
    k8s-master: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    k8s-master: Reading package lists...
    k8s-master: Building dependency tree...
    k8s-master: Reading state information...
    k8s-master: iptables is already the newest version (1.8.7-1ubuntu5.2).
    k8s-master: tmux is already the newest version (3.2a-4ubuntu0.2).
    k8s-master: The following additional packages will be installed:
    k8s-master:   keyutils libipset13 libjq1 libnfsidmap1 libonig5 rpcbind
    k8s-master: Suggested packages:
    k8s-master:   heartbeat keepalived ldirectord watchdog
    k8s-master: The following NEW packages will be installed:
    k8s-master:   arptables ebtables ipset ipvsadm jq keyutils libipset13 libjq1 libnfsidmap1
    k8s-master:   libonig5 net-tools nfs-common rpcbind
    k8s-master: 0 upgraded, 13 newly installed, 0 to remove and 77 not upgraded.
    k8s-master: Need to get 1,203 kB of archives.
    k8s-master: After this operation, 4,255 kB of additional disk space will be used.
    k8s-master: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libnfsidmap1 amd64 1:2.6.1-1ubuntu1.2 [42.9 kB]
    k8s-master: Get:2 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 rpcbind amd64 1.2.6-2build1 [46.6 kB]
    k8s-master: Get:3 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 keyutils amd64 1.6.1-2ubuntu3 [50.4 kB]
    k8s-master: Get:4 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 nfs-common amd64 1:2.6.1-1ubuntu1.2 [241 kB]
    k8s-master: Get:5 http://us.archive.ubuntu.com/ubuntu jammy/universe amd64 arptables amd64 0.0.5-3 [38.1 kB]
    k8s-master: Get:6 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 ebtables amd64 2.0.11-4build2 [84.9 kB]
    k8s-master: Get:7 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 libonig5 amd64 6.9.7.1-2build1 [172 kB]
    k8s-master: Get:8 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 libjq1 amd64 1.6-2.1ubuntu3 [133 kB]
    k8s-master: Get:9 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 jq amd64 1.6-2.1ubuntu3 [52.5 kB]
    k8s-master: Get:10 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 libipset13 amd64 7.15-1build1 [63.4 kB]
    k8s-master: Get:11 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 net-tools amd64 1.60+git20181103.0eebece-1ubuntu5 [204 kB]
    k8s-master: Get:12 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 ipset amd64 7.15-1build1 [32.8 kB]
    k8s-master: Get:13 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 ipvsadm amd64 1:1.31-1build2 [42.2 kB]
    k8s-master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-master: Fetched 1,203 kB in 2s (596 kB/s)
    k8s-master: Selecting previously unselected package libnfsidmap1:amd64.
(Reading database ... 44915 files and directories currently installed.)
    k8s-master: Preparing to unpack .../00-libnfsidmap1_1%3a2.6.1-1ubuntu1.2_amd64.deb ...
    k8s-master: Unpacking libnfsidmap1:amd64 (1:2.6.1-1ubuntu1.2) ...
    k8s-master: Selecting previously unselected package rpcbind.
    k8s-master: Preparing to unpack .../01-rpcbind_1.2.6-2build1_amd64.deb ...
    k8s-master: Unpacking rpcbind (1.2.6-2build1) ...
    k8s-master: Selecting previously unselected package keyutils.
    k8s-master: Preparing to unpack .../02-keyutils_1.6.1-2ubuntu3_amd64.deb ...
    k8s-master: Unpacking keyutils (1.6.1-2ubuntu3) ...
    k8s-master: Selecting previously unselected package nfs-common.
    k8s-master: Preparing to unpack .../03-nfs-common_1%3a2.6.1-1ubuntu1.2_amd64.deb ...
    k8s-master: Unpacking nfs-common (1:2.6.1-1ubuntu1.2) ...
    k8s-master: Selecting previously unselected package arptables.
    k8s-master: Preparing to unpack .../04-arptables_0.0.5-3_amd64.deb ...
    k8s-master: Unpacking arptables (0.0.5-3) ...
    k8s-master: Selecting previously unselected package ebtables.
    k8s-master: Preparing to unpack .../05-ebtables_2.0.11-4build2_amd64.deb ...
    k8s-master: Unpacking ebtables (2.0.11-4build2) ...
    k8s-master: Selecting previously unselected package libonig5:amd64.
    k8s-master: Preparing to unpack .../06-libonig5_6.9.7.1-2build1_amd64.deb ...
    k8s-master: Unpacking libonig5:amd64 (6.9.7.1-2build1) ...
    k8s-master: Selecting previously unselected package libjq1:amd64.
    k8s-master: Preparing to unpack .../07-libjq1_1.6-2.1ubuntu3_amd64.deb ...
    k8s-master: Unpacking libjq1:amd64 (1.6-2.1ubuntu3) ...
    k8s-master: Selecting previously unselected package jq.
    k8s-master: Preparing to unpack .../08-jq_1.6-2.1ubuntu3_amd64.deb ...
    k8s-master: Unpacking jq (1.6-2.1ubuntu3) ...
    k8s-master: Selecting previously unselected package libipset13:amd64.
    k8s-master: Preparing to unpack .../09-libipset13_7.15-1build1_amd64.deb ...
    k8s-master: Unpacking libipset13:amd64 (7.15-1build1) ...
    k8s-master: Selecting previously unselected package net-tools.
    k8s-master: Preparing to unpack .../10-net-tools_1.60+git20181103.0eebece-1ubuntu5_amd64.deb ...
    k8s-master: Unpacking net-tools (1.60+git20181103.0eebece-1ubuntu5) ...
    k8s-master: Selecting previously unselected package ipset.
    k8s-master: Preparing to unpack .../11-ipset_7.15-1build1_amd64.deb ...
    k8s-master: Unpacking ipset (7.15-1build1) ...
    k8s-master: Selecting previously unselected package ipvsadm.
    k8s-master: Preparing to unpack .../12-ipvsadm_1%3a1.31-1build2_amd64.deb ...
    k8s-master: Unpacking ipvsadm (1:1.31-1build2) ...
    k8s-master: Setting up ipvsadm (1:1.31-1build2) ...
    k8s-master: Setting up net-tools (1.60+git20181103.0eebece-1ubuntu5) ...
    k8s-master: Setting up libnfsidmap1:amd64 (1:2.6.1-1ubuntu1.2) ...
    k8s-master: Setting up rpcbind (1.2.6-2build1) ...
    k8s-master: Created symlink /etc/systemd/system/multi-user.target.wants/rpcbind.service → /lib/systemd/system/rpcbind.service.
    k8s-master: Created symlink /etc/systemd/system/sockets.target.wants/rpcbind.socket → /lib/systemd/system/rpcbind.socket.
    k8s-master: Setting up ebtables (2.0.11-4build2) ...
    k8s-master: Setting up arptables (0.0.5-3) ...
    k8s-master: Setting up keyutils (1.6.1-2ubuntu3) ...
    k8s-master: Setting up libipset13:amd64 (7.15-1build1) ...
    k8s-master: Setting up ipset (7.15-1build1) ...
    k8s-master: Setting up libonig5:amd64 (6.9.7.1-2build1) ...
    k8s-master: Setting up libjq1:amd64 (1.6-2.1ubuntu3) ...
    k8s-master: Setting up nfs-common (1:2.6.1-1ubuntu1.2) ...
    k8s-master: 
    k8s-master: Creating config file /etc/idmapd.conf with new version
    k8s-master: 
    k8s-master: Creating config file /etc/nfs.conf with new version
    k8s-master: Adding system user `statd' (UID 115) ...
    k8s-master: Adding new user `statd' (UID 115) with group `nogroup' ...
    k8s-master: Not creating home directory `/var/lib/nfs'.
    k8s-master: Created symlink /etc/systemd/system/multi-user.target.wants/nfs-client.target → /lib/systemd/system/nfs-client.target.
    k8s-master: Created symlink /etc/systemd/system/remote-fs.target.wants/nfs-client.target → /lib/systemd/system/nfs-client.target.
    k8s-master: auth-rpcgss-module.service is a disabled or a static unit, not starting it.
    k8s-master: nfs-idmapd.service is a disabled or a static unit, not starting it.
    k8s-master: nfs-utils.service is a disabled or a static unit, not starting it.
    k8s-master: proc-fs-nfsd.mount is a disabled or a static unit, not starting it.
    k8s-master: rpc-gssd.service is a disabled or a static unit, not starting it.
    k8s-master: rpc-statd-notify.service is a disabled or a static unit, not starting it.
    k8s-master: rpc-statd.service is a disabled or a static unit, not starting it.
    k8s-master: rpc-svcgssd.service is a disabled or a static unit, not starting it.
    k8s-master: rpc_pipefs.target is a disabled or a static unit, not starting it.
    k8s-master: var-lib-nfs-rpc_pipefs.mount is a disabled or a static unit, not starting it.
    k8s-master: Setting up jq (1.6-2.1ubuntu3) ...
    k8s-master: Processing triggers for man-db (2.10.2-1) ...
    k8s-master: Processing triggers for libc-bin (2.35-0ubuntu3.8) ...
    k8s-master: 
    k8s-master: Running kernel seems to be up-to-date.
    k8s-master:
    k8s-master: No services need to be restarted.
    k8s-master: 
    k8s-master: No containers need to be restarted.
    k8s-master:
    k8s-master: No user sessions are running outdated binaries.
    k8s-master:
    k8s-master: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    k8s-master: grub-pc set on hold.
    k8s-master: grub-pc-bin set on hold.
    k8s-master: grub2-common set on hold.
    k8s-master: grub-common set on hold.
    k8s-master: overlay
    k8s-master: br_netfilter
    k8s-master: net.bridge.bridge-nf-call-iptables  = 1
    k8s-master: net.bridge.bridge-nf-call-ip6tables = 1
    k8s-master: net.ipv4.ip_forward                 = 1
    k8s-master: net.ipv4.ip_forward = 1
    k8s-master: * Applying /etc/sysctl.d/10-console-messages.conf ...
    k8s-master: kernel.printk = 4 4 1 7
    k8s-master: * Applying /etc/sysctl.d/10-ipv6-privacy.conf ...
    k8s-master: net.ipv6.conf.all.use_tempaddr = 2
    k8s-master: net.ipv6.conf.default.use_tempaddr = 2
    k8s-master: * Applying /etc/sysctl.d/10-kernel-hardening.conf ...
    k8s-master: kernel.kptr_restrict = 1
    k8s-master: * Applying /etc/sysctl.d/10-magic-sysrq.conf ...
    k8s-master: kernel.sysrq = 176
    k8s-master: * Applying /etc/sysctl.d/10-network-security.conf ...
    k8s-master: net.ipv4.conf.default.rp_filter = 2
    k8s-master: net.ipv4.conf.all.rp_filter = 2
    k8s-master: * Applying /etc/sysctl.d/10-ptrace.conf ...
    k8s-master: kernel.yama.ptrace_scope = 1
    k8s-master: * Applying /etc/sysctl.d/10-zeropage.conf ...
    k8s-master: vm.mmap_min_addr = 65536
    k8s-master: * Applying /usr/lib/sysctl.d/50-default.conf ...
    k8s-master: kernel.core_uses_pid = 1
    k8s-master: net.ipv4.conf.default.rp_filter = 2
    k8s-master: net.ipv4.conf.default.accept_source_route = 0
    k8s-master: net.ipv4.conf.default.promote_secondaries = 1
    k8s-master: sysctl: setting key "net.ipv4.conf.all.accept_source_route": Invalid argument
    k8s-master: sysctl: setting key "net.ipv4.conf.all.promote_secondaries": Invalid argument
    k8s-master: net.ipv4.ping_group_range = 0 2147483647
    k8s-master: net.core.default_qdisc = fq_codel
    k8s-master: fs.protected_hardlinks = 1
    k8s-master: fs.protected_symlinks = 1
    k8s-master: fs.protected_regular = 1
    k8s-master: fs.protected_fifos = 1
    k8s-master: * Applying /usr/lib/sysctl.d/50-pid-max.conf ...
    k8s-master: kernel.pid_max = 4194304
    k8s-master: * Applying /usr/lib/sysctl.d/99-protect-links.conf ...
    k8s-master: fs.protected_fifos = 1
    k8s-master: fs.protected_hardlinks = 1
    k8s-master: fs.protected_regular = 2
    k8s-master: fs.protected_symlinks = 1
    k8s-master: * Applying /etc/sysctl.d/99-sysctl.conf ...
    k8s-master: * Applying /etc/sysctl.d/k8s.conf ...
    k8s-master: net.ipv4.ip_forward = 1
    k8s-master: * Applying /etc/sysctl.conf ...
    k8s-master: net.ipv4.ip_forward = 1
    k8s-master: Hit:1 http://us.archive.ubuntu.com/ubuntu jammy InRelease
    k8s-master: Hit:2 http://security.ubuntu.com/ubuntu jammy-security InRelease
    k8s-master: Hit:3 http://us.archive.ubuntu.com/ubuntu jammy-updates InRelease
    k8s-master: Hit:4 http://us.archive.ubuntu.com/ubuntu jammy-backports InRelease
    k8s-master: Reading package lists...
    k8s-master: Reading package lists...
    k8s-master: Building dependency tree...
    k8s-master: Reading state information...
    k8s-master: Calculating upgrade...
    k8s-master: The following NEW packages will be installed:
    k8s-master:   linux-image-5.15.0-130-generic linux-modules-5.15.0-130-generic
    k8s-master:   linux-modules-extra-5.15.0-130-generic python3-packaging
    k8s-master: The following packages have been kept back:
    k8s-master:   bind9-dnsutils bind9-host bind9-libs
    k8s-master: The following packages will be upgraded:
    k8s-master:   amd64-microcode apparmor apport apt apt-utils base-files busybox-initramfs
    k8s-master:   busybox-static cloud-init distro-info-data dmidecode e2fsprogs
    k8s-master:   gir1.2-packagekitglib-1.0 intel-microcode libapparmor1 libapt-pkg6.0
    k8s-master:   libarchive13 libcom-err2 libcurl3-gnutls libexpat1 libext2fs2 libglib2.0-0
    k8s-master:   libglib2.0-bin libglib2.0-data libgssapi-krb5-2 libgstreamer1.0-0
    k8s-master:   libk5crypto3 libkrb5-3 libkrb5support0 libldap-2.5-0 libldap-common
    k8s-master:   libmm-glib0 libmodule-scandeps-perl libpackagekit-glib2-18 libpcap0.8
    k8s-master:   libpython3-stdlib libpython3.10 libpython3.10-minimal libpython3.10-stdlib
    k8s-master:   libss2 libssl3 linux-firmware linux-image-generic logsave modemmanager nano
    k8s-master:   needrestart openssl packagekit packagekit-tools python-apt-common python3
    k8s-master:   python3-apport python3-apt python3-configobj python3-minimal
    k8s-master:   python3-pkg-resources python3-problem-report python3-setuptools
    k8s-master:   python3-twisted python3-urllib3 python3.10 python3.10-minimal snapd
    k8s-master:   sosreport ubuntu-advantage-tools ubuntu-minimal ubuntu-pro-client
    k8s-master:   ubuntu-pro-client-l10n vim vim-common vim-runtime vim-tiny xxd
    k8s-master: 74 upgraded, 4 newly installed, 0 to remove and 3 not upgraded.
    k8s-master: Need to get 481 MB of archives.
    k8s-master: After this operation, 532 MB of additional disk space will be used.
    k8s-master: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 base-files amd64 12ubuntu4.7 [61.9 kB]
    k8s-master: Get:2 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libapt-pkg6.0 amd64 2.4.13 [912 kB]
    k8s-master: Get:3 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 apt amd64 2.4.13 [1,363 kB]
    k8s-master: Get:4 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 apt-utils amd64 2.4.13 [211 kB]
    k8s-master: Get:5 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 logsave amd64 1.46.5-2ubuntu1.2 [10.1 kB]
    k8s-master: Get:6 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libext2fs2 amd64 1.46.5-2ubuntu1.2 [208 kB]
    k8s-master: Get:7 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 e2fsprogs amd64 1.46.5-2ubuntu1.2 [590 kB]
    k8s-master: Get:8 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-minimal amd64 3.10.6-1~22.04.1 [24.3 kB]
    k8s-master: Get:9 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3 amd64 3.10.6-1~22.04.1 [22.8 kB]
    k8s-master: Get:10 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libexpat1 amd64 2.4.7-1ubuntu0.5 [91.5 kB]
    k8s-master: Get:11 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpython3.10 amd64 3.10.12-1~22.04.7 [1,949 kB]
    k8s-master: Get:12 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3.10 amd64 3.10.12-1~22.04.7 [509 kB]
    k8s-master: Get:13 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpython3.10-stdlib amd64 3.10.12-1~22.04.7 [1,850 kB]
    k8s-master: Get:14 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libssl3 amd64 3.0.2-0ubuntu1.18 [1,905 kB]
    k8s-master: Get:15 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3.10-minimal amd64 3.10.12-1~22.04.7 [2,279 kB]
    k8s-master: Get:16 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpython3.10-minimal amd64 3.10.12-1~22.04.7 [814 kB]
    k8s-master: Get:17 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpython3-stdlib amd64 3.10.6-1~22.04.1 [6,812 B]
    k8s-master: Get:18 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libcom-err2 amd64 1.46.5-2ubuntu1.2 [9,304 B]
    k8s-master: Get:19 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libk5crypto3 amd64 1.19.2-2ubuntu0.4 [86.3 kB]
    k8s-master: Get:20 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libkrb5support0 amd64 1.19.2-2ubuntu0.4 [32.3 kB]
    k8s-master: Get:21 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libkrb5-3 amd64 1.19.2-2ubuntu0.4 [356 kB]
    k8s-master: Get:22 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libgssapi-krb5-2 amd64 1.19.2-2ubuntu0.4 [144 kB]
    k8s-master: Get:23 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libss2 amd64 1.46.5-2ubuntu1.2 [12.3 kB]
    k8s-master: Get:24 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 distro-info-data all 0.52ubuntu0.8 [5,302 B]
    k8s-master: Get:25 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libapparmor1 amd64 3.0.4-2ubuntu2.4 [39.7 kB]
    k8s-master: Get:26 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libglib2.0-data all 2.72.4-0ubuntu2.4 [4,582 B]
    k8s-master: Get:27 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libglib2.0-bin amd64 2.72.4-0ubuntu2.4 [80.9 kB]
    k8s-master: Get:28 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libglib2.0-0 amd64 2.72.4-0ubuntu2.4 [1,465 kB]
    k8s-master: Get:29 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 openssl amd64 3.0.2-0ubuntu1.18 [1,184 kB]
    k8s-master: Get:30 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python-apt-common all 2.4.0ubuntu4 [14.6 kB]
    k8s-master: Get:31 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-apt amd64 2.4.0ubuntu4 [164 kB]
    k8s-master: Get:32 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-setuptools all 59.6.0-1.2ubuntu0.22.04.2 [340 kB]
    k8s-master: Get:33 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-pkg-resources all 59.6.0-1.2ubuntu0.22.04.2 [133 kB]
    k8s-master: Get:34 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 ubuntu-pro-client-l10n amd64 34~22.04 [19.1 kB]
    k8s-master: Get:35 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 ubuntu-pro-client amd64 34~22.04 [221 kB]
    k8s-master: Get:36 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 ubuntu-advantage-tools all 34~22.04 [10.9 kB]
    k8s-master: Get:37 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 xxd amd64 2:8.2.3995-1ubuntu2.21 [52.3 kB]
    k8s-master: Get:38 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 vim amd64 2:8.2.3995-1ubuntu2.21 [1,729 kB]
    k8s-master: Get:39 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 vim-tiny amd64 2:8.2.3995-1ubuntu2.21 [708 kB]
    k8s-master: Get:40 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 vim-runtime all 2:8.2.3995-1ubuntu2.21 [6,834 kB]
    k8s-master: Get:41 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 vim-common all 2:8.2.3995-1ubuntu2.21 [81.5 kB]
    k8s-master: Get:42 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 ubuntu-minimal amd64 1.481.4 [2,928 B]
    k8s-master: Get:43 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 apparmor amd64 3.0.4-2ubuntu2.4 [598 kB]
    k8s-master: Get:44 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 busybox-static amd64 1:1.30.1-7ubuntu3.1 [1,019 kB]
    k8s-master: Get:45 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 dmidecode amd64 3.3-3ubuntu0.2 [68.5 kB]
    k8s-master: Get:46 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpcap0.8 amd64 1.10.1-4ubuntu1.22.04.1 [145 kB]
    k8s-master: Get:47 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 nano amd64 6.2-1ubuntu0.1 [280 kB]
    k8s-master: Get:48 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-problem-report all 2.20.11-0ubuntu82.6 [11.1 kB]
    k8s-master: Get:49 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-apport all 2.20.11-0ubuntu82.6 [89.0 kB]
    k8s-master: Get:50 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 apport all 2.20.11-0ubuntu82.6 [134 kB]
    k8s-master: Get:51 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 busybox-initramfs amd64 1:1.30.1-7ubuntu3.1 [177 kB]
    k8s-master: Get:52 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpackagekit-glib2-18 amd64 1.2.5-2ubuntu3 [124 kB]
    k8s-master: Get:53 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 gir1.2-packagekitglib-1.0 amd64 1.2.5-2ubuntu3 [25.3 kB]
    k8s-master: Get:54 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libarchive13 amd64 3.6.0-1ubuntu1.3 [369 kB]
    k8s-master: Get:55 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libldap-2.5-0 amd64 2.5.18+dfsg-0ubuntu0.22.04.2 [183 kB]
    k8s-master: Get:56 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libcurl3-gnutls amd64 7.81.0-1ubuntu1.20 [284 kB]
    k8s-master: Get:57 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libgstreamer1.0-0 amd64 1.20.3-0ubuntu1.1 [984 kB]
    k8s-master: Get:58 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libldap-common all 2.5.18+dfsg-0ubuntu0.22.04.2 [15.9 kB]
    k8s-master: Get:59 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libmm-glib0 amd64 1.20.0-1~ubuntu22.04.4 [262 kB]
    k8s-master: Get:60 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libmodule-scandeps-perl all 1.31-1ubuntu0.1 [30.7 kB]
    k8s-master: Get:61 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-firmware all 20220329.git681281e4-0ubuntu3.36 [312 MB]
    k8s-master: Get:62 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-modules-5.15.0-130-generic amd64 5.15.0-130.140 [22.7 MB]
    k8s-master: Get:63 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-image-5.15.0-130-generic amd64 5.15.0-130.140 [11.6 MB]
    k8s-master: Get:64 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-modules-extra-5.15.0-130-generic amd64 5.15.0-130.140 [63.9 MB]
    k8s-master: Get:65 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 amd64-microcode amd64 3.20191218.1ubuntu2.3 [67.9 kB]
    k8s-master: Get:66 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 intel-microcode amd64 3.20241112.0ubuntu0.22.04.1 [7,045 kB]
    k8s-master: Get:67 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-image-generic amd64 5.15.0.130.128 [2,524 B]
    k8s-master: Get:68 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 modemmanager amd64 1.20.0-1~ubuntu22.04.4 [1,094 kB]
    k8s-master: Get:69 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 needrestart all 3.5-5ubuntu2.4 [45.2 kB]
    k8s-master: Get:70 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 packagekit-tools amd64 1.2.5-2ubuntu3 [28.8 kB]
    k8s-master: Get:71 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 packagekit amd64 1.2.5-2ubuntu3 [442 kB]
    k8s-master: Get:72 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-configobj all 5.0.6-5ubuntu0.1 [34.9 kB]
    k8s-master: Get:73 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 python3-packaging all 21.3-1 [30.7 kB]
    k8s-master: Get:74 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-twisted all 22.1.0-2ubuntu2.6 [2,007 kB]
    k8s-master: Get:75 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-urllib3 all 1.26.5-1~exp1ubuntu0.2 [98.3 kB]
    k8s-master: Get:76 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 snapd amd64 2.66.1+22.04 [27.6 MB]
    k8s-master: Get:77 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 sosreport amd64 4.7.2-0ubuntu1~22.04.2 [352 kB]
    k8s-master: Get:78 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 cloud-init all 24.4-0ubuntu1~22.04.1 [565 kB]
    k8s-master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-master: Fetched 481 MB in 19s (25.4 MB/s)
(Reading database ... 45178 files and directories currently installed.)
    k8s-master: Preparing to unpack .../base-files_12ubuntu4.7_amd64.deb ...
    k8s-master: Unpacking base-files (12ubuntu4.7) over (12ubuntu4.6) ...
    k8s-master: Setting up base-files (12ubuntu4.7) ...
    k8s-master: Installing new version of config file /etc/issue ...
    k8s-master: Installing new version of config file /etc/issue.net ...
    k8s-master: Installing new version of config file /etc/lsb-release ...
    k8s-master: motd-news.service is a disabled or a static unit not running, not starting it.
(Reading database ... 45178 files and directories currently installed.)
    k8s-master: Preparing to unpack .../libapt-pkg6.0_2.4.13_amd64.deb ...
    k8s-master: Unpacking libapt-pkg6.0:amd64 (2.4.13) over (2.4.12) ...
    k8s-master: Setting up libapt-pkg6.0:amd64 (2.4.13) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-master: Preparing to unpack .../archives/apt_2.4.13_amd64.deb ...
    k8s-master: Unpacking apt (2.4.13) over (2.4.12) ...
    k8s-master: Setting up apt (2.4.13) ...
    k8s-master: apt-daily-upgrade.timer is a disabled or a static unit not running, not starting it.
    k8s-master: apt-daily.timer is a disabled or a static unit not running, not starting it.
(Reading database ... 45178 files and directories currently installed.)
    k8s-master: Preparing to unpack .../apt-utils_2.4.13_amd64.deb ...
    k8s-master: Unpacking apt-utils (2.4.13) over (2.4.12) ...
    k8s-master: Preparing to unpack .../logsave_1.46.5-2ubuntu1.2_amd64.deb ...
    k8s-master: Unpacking logsave (1.46.5-2ubuntu1.2) over (1.46.5-2ubuntu1.1) ...
    k8s-master: Preparing to unpack .../libext2fs2_1.46.5-2ubuntu1.2_amd64.deb ...
    k8s-master: Unpacking libext2fs2:amd64 (1.46.5-2ubuntu1.2) over (1.46.5-2ubuntu1.1) ...
    k8s-master: Setting up libext2fs2:amd64 (1.46.5-2ubuntu1.2) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-master: Preparing to unpack .../e2fsprogs_1.46.5-2ubuntu1.2_amd64.deb ...
    k8s-master: Unpacking e2fsprogs (1.46.5-2ubuntu1.2) over (1.46.5-2ubuntu1.1) ...
    k8s-master: Preparing to unpack .../python3-minimal_3.10.6-1~22.04.1_amd64.deb ...
    k8s-master: Unpacking python3-minimal (3.10.6-1~22.04.1) over (3.10.6-1~22.04) ...
    k8s-master: Setting up python3-minimal (3.10.6-1~22.04.1) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-master: Preparing to unpack .../0-python3_3.10.6-1~22.04.1_amd64.deb ...
    k8s-master: running python pre-rtupdate hooks for python3.10...
    k8s-master: Unpacking python3 (3.10.6-1~22.04.1) over (3.10.6-1~22.04) ...
    k8s-master: Preparing to unpack .../1-libexpat1_2.4.7-1ubuntu0.5_amd64.deb ...
    k8s-master: Unpacking libexpat1:amd64 (2.4.7-1ubuntu0.5) over (2.4.7-1ubuntu0.3) ...
    k8s-master: Preparing to unpack .../2-libpython3.10_3.10.12-1~22.04.7_amd64.deb ...
    k8s-master: Unpacking libpython3.10:amd64 (3.10.12-1~22.04.7) over (3.10.12-1~22.04.4) ...
    k8s-master: Preparing to unpack .../3-python3.10_3.10.12-1~22.04.7_amd64.deb ...
    k8s-master: Unpacking python3.10 (3.10.12-1~22.04.7) over (3.10.12-1~22.04.4) ...
    k8s-master: Preparing to unpack .../4-libpython3.10-stdlib_3.10.12-1~22.04.7_amd64.deb ...
    k8s-master: Unpacking libpython3.10-stdlib:amd64 (3.10.12-1~22.04.7) over (3.10.12-1~22.04.4) ...
    k8s-master: Preparing to unpack .../5-libssl3_3.0.2-0ubuntu1.18_amd64.deb ...
    k8s-master: Unpacking libssl3:amd64 (3.0.2-0ubuntu1.18) over (3.0.2-0ubuntu1.16) ...
    k8s-master: Setting up libssl3:amd64 (3.0.2-0ubuntu1.18) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-master: Preparing to unpack .../python3.10-minimal_3.10.12-1~22.04.7_amd64.deb ...
    k8s-master: Unpacking python3.10-minimal (3.10.12-1~22.04.7) over (3.10.12-1~22.04.4) ...
    k8s-master: Preparing to unpack .../libpython3.10-minimal_3.10.12-1~22.04.7_amd64.deb ...
    k8s-master: Unpacking libpython3.10-minimal:amd64 (3.10.12-1~22.04.7) over (3.10.12-1~22.04.4) ...
    k8s-master: Preparing to unpack .../libpython3-stdlib_3.10.6-1~22.04.1_amd64.deb ...
    k8s-master: Unpacking libpython3-stdlib:amd64 (3.10.6-1~22.04.1) over (3.10.6-1~22.04) ...
    k8s-master: Preparing to unpack .../libcom-err2_1.46.5-2ubuntu1.2_amd64.deb ...
    k8s-master: Unpacking libcom-err2:amd64 (1.46.5-2ubuntu1.2) over (1.46.5-2ubuntu1.1) ...
    k8s-master: Setting up libcom-err2:amd64 (1.46.5-2ubuntu1.2) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-master: Preparing to unpack .../libk5crypto3_1.19.2-2ubuntu0.4_amd64.deb ...
    k8s-master: Unpacking libk5crypto3:amd64 (1.19.2-2ubuntu0.4) over (1.19.2-2ubuntu0.3) ...
    k8s-master: Setting up libk5crypto3:amd64 (1.19.2-2ubuntu0.4) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-master: Preparing to unpack .../libkrb5support0_1.19.2-2ubuntu0.4_amd64.deb ...
    k8s-master: Unpacking libkrb5support0:amd64 (1.19.2-2ubuntu0.4) over (1.19.2-2ubuntu0.3) ...
    k8s-master: Setting up libkrb5support0:amd64 (1.19.2-2ubuntu0.4) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-master: Preparing to unpack .../libkrb5-3_1.19.2-2ubuntu0.4_amd64.deb ...
    k8s-master: Unpacking libkrb5-3:amd64 (1.19.2-2ubuntu0.4) over (1.19.2-2ubuntu0.3) ...
    k8s-master: Setting up libkrb5-3:amd64 (1.19.2-2ubuntu0.4) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-master: Preparing to unpack .../libgssapi-krb5-2_1.19.2-2ubuntu0.4_amd64.deb ...
    k8s-master: Unpacking libgssapi-krb5-2:amd64 (1.19.2-2ubuntu0.4) over (1.19.2-2ubuntu0.3) ...
    k8s-master: Setting up libgssapi-krb5-2:amd64 (1.19.2-2ubuntu0.4) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-master: Preparing to unpack .../00-libss2_1.46.5-2ubuntu1.2_amd64.deb ...
    k8s-master: Unpacking libss2:amd64 (1.46.5-2ubuntu1.2) over (1.46.5-2ubuntu1.1) ...
    k8s-master: Preparing to unpack .../01-distro-info-data_0.52ubuntu0.8_all.deb ...
    k8s-master: Unpacking distro-info-data (0.52ubuntu0.8) over (0.52ubuntu0.7) ...
    k8s-master: Preparing to unpack .../02-libapparmor1_3.0.4-2ubuntu2.4_amd64.deb ...
    k8s-master: Unpacking libapparmor1:amd64 (3.0.4-2ubuntu2.4) over (3.0.4-2ubuntu2.3) ...
    k8s-master: Preparing to unpack .../03-libglib2.0-data_2.72.4-0ubuntu2.4_all.deb ...
    k8s-master: Unpacking libglib2.0-data (2.72.4-0ubuntu2.4) over (2.72.4-0ubuntu2.3) ...
    k8s-master: Preparing to unpack .../04-libglib2.0-bin_2.72.4-0ubuntu2.4_amd64.deb ...
    k8s-master: Unpacking libglib2.0-bin (2.72.4-0ubuntu2.4) over (2.72.4-0ubuntu2.3) ...
    k8s-master: Preparing to unpack .../05-libglib2.0-0_2.72.4-0ubuntu2.4_amd64.deb ...
    k8s-master: Unpacking libglib2.0-0:amd64 (2.72.4-0ubuntu2.4) over (2.72.4-0ubuntu2.3) ...
    k8s-master: Preparing to unpack .../06-openssl_3.0.2-0ubuntu1.18_amd64.deb ...
    k8s-master: Unpacking openssl (3.0.2-0ubuntu1.18) over (3.0.2-0ubuntu1.16) ...
    k8s-master: Preparing to unpack .../07-python-apt-common_2.4.0ubuntu4_all.deb ...
    k8s-master: Unpacking python-apt-common (2.4.0ubuntu4) over (2.4.0ubuntu3) ...
    k8s-master: Preparing to unpack .../08-python3-apt_2.4.0ubuntu4_amd64.deb ...
    k8s-master: Unpacking python3-apt (2.4.0ubuntu4) over (2.4.0ubuntu3) ...
    k8s-master: Preparing to unpack .../09-python3-setuptools_59.6.0-1.2ubuntu0.22.04.2_all.deb ...
    k8s-master: Unpacking python3-setuptools (59.6.0-1.2ubuntu0.22.04.2) over (59.6.0-1.2ubuntu0.22.04.1) ...
    k8s-master: Preparing to unpack .../10-python3-pkg-resources_59.6.0-1.2ubuntu0.22.04.2_all.deb ...
    k8s-master: Unpacking python3-pkg-resources (59.6.0-1.2ubuntu0.22.04.2) over (59.6.0-1.2ubuntu0.22.04.1) ...
    k8s-master: Preparing to unpack .../11-ubuntu-pro-client-l10n_34~22.04_amd64.deb ...
    k8s-master: Unpacking ubuntu-pro-client-l10n (34~22.04) over (32.3.1~22.04) ...
    k8s-master: Preparing to unpack .../12-ubuntu-pro-client_34~22.04_amd64.deb ...
    k8s-master: Unpacking ubuntu-pro-client (34~22.04) over (32.3.1~22.04) ...
    k8s-master: Preparing to unpack .../13-ubuntu-advantage-tools_34~22.04_all.deb ...
    k8s-master: Unpacking ubuntu-advantage-tools (34~22.04) over (32.3.1~22.04) ...
    k8s-master: Preparing to unpack .../14-xxd_2%3a8.2.3995-1ubuntu2.21_amd64.deb ...
    k8s-master: Unpacking xxd (2:8.2.3995-1ubuntu2.21) over (2:8.2.3995-1ubuntu2.17) ...
    k8s-master: Preparing to unpack .../15-vim_2%3a8.2.3995-1ubuntu2.21_amd64.deb ...
    k8s-master: Unpacking vim (2:8.2.3995-1ubuntu2.21) over (2:8.2.3995-1ubuntu2.17) ...
    k8s-master: Preparing to unpack .../16-vim-tiny_2%3a8.2.3995-1ubuntu2.21_amd64.deb ...
    k8s-master: Unpacking vim-tiny (2:8.2.3995-1ubuntu2.21) over (2:8.2.3995-1ubuntu2.17) ...
    k8s-master: Preparing to unpack .../17-vim-runtime_2%3a8.2.3995-1ubuntu2.21_all.deb ...
    k8s-master: Unpacking vim-runtime (2:8.2.3995-1ubuntu2.21) over (2:8.2.3995-1ubuntu2.17) ...
    k8s-master: Preparing to unpack .../18-vim-common_2%3a8.2.3995-1ubuntu2.21_all.deb ...
    k8s-master: Unpacking vim-common (2:8.2.3995-1ubuntu2.21) over (2:8.2.3995-1ubuntu2.17) ...
    k8s-master: Preparing to unpack .../19-ubuntu-minimal_1.481.4_amd64.deb ...
    k8s-master: Unpacking ubuntu-minimal (1.481.4) over (1.481.2) ...
    k8s-master: Preparing to unpack .../20-apparmor_3.0.4-2ubuntu2.4_amd64.deb ...
    k8s-master: Unpacking apparmor (3.0.4-2ubuntu2.4) over (3.0.4-2ubuntu2.3) ...
    k8s-master: Preparing to unpack .../21-busybox-static_1%3a1.30.1-7ubuntu3.1_amd64.deb ...
    k8s-master: Unpacking busybox-static (1:1.30.1-7ubuntu3.1) over (1:1.30.1-7ubuntu3) ...
    k8s-master: Preparing to unpack .../22-dmidecode_3.3-3ubuntu0.2_amd64.deb ...
    k8s-master: Unpacking dmidecode (3.3-3ubuntu0.2) over (3.3-3ubuntu0.1) ...
    k8s-master: Preparing to unpack .../23-libpcap0.8_1.10.1-4ubuntu1.22.04.1_amd64.deb ...
    k8s-master: Unpacking libpcap0.8:amd64 (1.10.1-4ubuntu1.22.04.1) over (1.10.1-4build1) ...
    k8s-master: Preparing to unpack .../24-nano_6.2-1ubuntu0.1_amd64.deb ...
    k8s-master: Unpacking nano (6.2-1ubuntu0.1) over (6.2-1) ...
    k8s-master: Preparing to unpack .../25-python3-problem-report_2.20.11-0ubuntu82.6_all.deb ...
    k8s-master: Unpacking python3-problem-report (2.20.11-0ubuntu82.6) over (2.20.11-0ubuntu82.5) ...
    k8s-master: Preparing to unpack .../26-python3-apport_2.20.11-0ubuntu82.6_all.deb ...
    k8s-master: Unpacking python3-apport (2.20.11-0ubuntu82.6) over (2.20.11-0ubuntu82.5) ...
    k8s-master: Preparing to unpack .../27-apport_2.20.11-0ubuntu82.6_all.deb ...
    k8s-master: Unpacking apport (2.20.11-0ubuntu82.6) over (2.20.11-0ubuntu82.5) ...
    k8s-master: Preparing to unpack .../28-busybox-initramfs_1%3a1.30.1-7ubuntu3.1_amd64.deb ...
    k8s-master: Unpacking busybox-initramfs (1:1.30.1-7ubuntu3.1) over (1:1.30.1-7ubuntu3) ...
    k8s-master: Preparing to unpack .../29-libpackagekit-glib2-18_1.2.5-2ubuntu3_amd64.deb ...
    k8s-master: Unpacking libpackagekit-glib2-18:amd64 (1.2.5-2ubuntu3) over (1.2.5-2ubuntu2) ...
    k8s-master: Preparing to unpack .../30-gir1.2-packagekitglib-1.0_1.2.5-2ubuntu3_amd64.deb ...
    k8s-master: Unpacking gir1.2-packagekitglib-1.0 (1.2.5-2ubuntu3) over (1.2.5-2ubuntu2) ...
    k8s-master: Preparing to unpack .../31-libarchive13_3.6.0-1ubuntu1.3_amd64.deb ...
    k8s-master: Unpacking libarchive13:amd64 (3.6.0-1ubuntu1.3) over (3.6.0-1ubuntu1.1) ...
    k8s-master: Preparing to unpack .../32-libldap-2.5-0_2.5.18+dfsg-0ubuntu0.22.04.2_amd64.deb ...
    k8s-master: Unpacking libldap-2.5-0:amd64 (2.5.18+dfsg-0ubuntu0.22.04.2) over (2.5.18+dfsg-0ubuntu0.22.04.1) ...
    k8s-master: Preparing to unpack .../33-libcurl3-gnutls_7.81.0-1ubuntu1.20_amd64.deb ...
    k8s-master: Unpacking libcurl3-gnutls:amd64 (7.81.0-1ubuntu1.20) over (7.81.0-1ubuntu1.16) ...
    k8s-master: Preparing to unpack .../34-libgstreamer1.0-0_1.20.3-0ubuntu1.1_amd64.deb ...
    k8s-master: Unpacking libgstreamer1.0-0:amd64 (1.20.3-0ubuntu1.1) over (1.20.3-0ubuntu1) ...
    k8s-master: Preparing to unpack .../35-libldap-common_2.5.18+dfsg-0ubuntu0.22.04.2_all.deb ...
    k8s-master: Unpacking libldap-common (2.5.18+dfsg-0ubuntu0.22.04.2) over (2.5.18+dfsg-0ubuntu0.22.04.1) ...
    k8s-master: Preparing to unpack .../36-libmm-glib0_1.20.0-1~ubuntu22.04.4_amd64.deb ...
    k8s-master: Unpacking libmm-glib0:amd64 (1.20.0-1~ubuntu22.04.4) over (1.20.0-1~ubuntu22.04.3) ...
    k8s-master: Preparing to unpack .../37-libmodule-scandeps-perl_1.31-1ubuntu0.1_all.deb ...
    k8s-master: Unpacking libmodule-scandeps-perl (1.31-1ubuntu0.1) over (1.31-1) ...
    k8s-master: Preparing to unpack .../38-linux-firmware_20220329.git681281e4-0ubuntu3.36_all.deb ...
    k8s-master: Unpacking linux-firmware (20220329.git681281e4-0ubuntu3.36) over (20220329.git681281e4-0ubuntu3.31) ...
    k8s-master: Selecting previously unselected package linux-modules-5.15.0-130-generic.
    k8s-master: Preparing to unpack .../39-linux-modules-5.15.0-130-generic_5.15.0-130.140_amd64.deb ...
    k8s-master: Unpacking linux-modules-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: Selecting previously unselected package linux-image-5.15.0-130-generic.
    k8s-master: Preparing to unpack .../40-linux-image-5.15.0-130-generic_5.15.0-130.140_amd64.deb ...
    k8s-master: Unpacking linux-image-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: Selecting previously unselected package linux-modules-extra-5.15.0-130-generic.
    k8s-master: Preparing to unpack .../41-linux-modules-extra-5.15.0-130-generic_5.15.0-130.140_amd64.deb ...
    k8s-master: Unpacking linux-modules-extra-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: Preparing to unpack .../42-amd64-microcode_3.20191218.1ubuntu2.3_amd64.deb ...
    k8s-master: Unpacking amd64-microcode (3.20191218.1ubuntu2.3) over (3.20191218.1ubuntu2.2) ...
    k8s-master: Preparing to unpack .../43-intel-microcode_3.20241112.0ubuntu0.22.04.1_amd64.deb ...
    k8s-master: Unpacking intel-microcode (3.20241112.0ubuntu0.22.04.1) over (3.20240514.0ubuntu0.22.04.1) ...
    k8s-master: Preparing to unpack .../44-linux-image-generic_5.15.0.130.128_amd64.deb ...
    k8s-master: Unpacking linux-image-generic (5.15.0.130.128) over (5.15.0.116.116) ...
    k8s-master: Preparing to unpack .../45-modemmanager_1.20.0-1~ubuntu22.04.4_amd64.deb ...
    k8s-master: Unpacking modemmanager (1.20.0-1~ubuntu22.04.4) over (1.20.0-1~ubuntu22.04.3) ...
    k8s-master: Preparing to unpack .../46-needrestart_3.5-5ubuntu2.4_all.deb ...
    k8s-master: Unpacking needrestart (3.5-5ubuntu2.4) over (3.5-5ubuntu2.1) ...
    k8s-master: Preparing to unpack .../47-packagekit-tools_1.2.5-2ubuntu3_amd64.deb ...
    k8s-master: Unpacking packagekit-tools (1.2.5-2ubuntu3) over (1.2.5-2ubuntu2) ...
    k8s-master: Preparing to unpack .../48-packagekit_1.2.5-2ubuntu3_amd64.deb ...
    k8s-master: Unpacking packagekit (1.2.5-2ubuntu3) over (1.2.5-2ubuntu2) ...
    k8s-master: Preparing to unpack .../49-python3-configobj_5.0.6-5ubuntu0.1_all.deb ...
    k8s-master: Unpacking python3-configobj (5.0.6-5ubuntu0.1) over (5.0.6-5) ...
    k8s-master: Selecting previously unselected package python3-packaging.
    k8s-master: Preparing to unpack .../50-python3-packaging_21.3-1_all.deb ...
    k8s-master: Unpacking python3-packaging (21.3-1) ...
    k8s-master: Preparing to unpack .../51-python3-twisted_22.1.0-2ubuntu2.6_all.deb ...
    k8s-master: Unpacking python3-twisted (22.1.0-2ubuntu2.6) over (22.1.0-2ubuntu2.4) ...
    k8s-master: Preparing to unpack .../52-python3-urllib3_1.26.5-1~exp1ubuntu0.2_all.deb ...
    k8s-master: Unpacking python3-urllib3 (1.26.5-1~exp1ubuntu0.2) over (1.26.5-1~exp1ubuntu0.1) ...
    k8s-master: Preparing to unpack .../53-snapd_2.66.1+22.04_amd64.deb ...
    k8s-master: Unpacking snapd (2.66.1+22.04) over (2.63+22.04) ...
    k8s-master: Preparing to unpack .../54-sosreport_4.7.2-0ubuntu1~22.04.2_amd64.deb ...
    k8s-master: Unpacking sosreport (4.7.2-0ubuntu1~22.04.2) over (4.5.6-0ubuntu1~22.04.2) ...
    k8s-master: Preparing to unpack .../55-cloud-init_24.4-0ubuntu1~22.04.1_all.deb ...
    k8s-master: Unpacking cloud-init (24.4-0ubuntu1~22.04.1) over (24.1.3-0ubuntu1~22.04.5) ...
    k8s-master: dpkg: warning: unable to delete old directory '/etc/systemd/system/sshd-keygen@.service.d': Directory not empty
    k8s-master: Setting up libexpat1:amd64 (2.4.7-1ubuntu0.5) ...
    k8s-master: Setting up libapparmor1:amd64 (3.0.4-2ubuntu2.4) ...
    k8s-master: Setting up apt-utils (2.4.13) ...
    k8s-master: Setting up linux-firmware (20220329.git681281e4-0ubuntu3.36) ...
    k8s-master: update-initramfs: Generating /boot/initrd.img-5.15.0-116-generic
    k8s-master: find: ‘/var/tmp/mkinitramfs_UgJi4A/lib/firmware’: No such file or directory
    k8s-master: Setting up libarchive13:amd64 (3.6.0-1ubuntu1.3) ...
    k8s-master: Setting up libglib2.0-0:amd64 (2.72.4-0ubuntu2.4) ...
    k8s-master: No schema files found: doing nothing.
    k8s-master: Setting up distro-info-data (0.52ubuntu0.8) ...
    k8s-master: Setting up intel-microcode (3.20241112.0ubuntu0.22.04.1) ...
    k8s-master: update-initramfs: deferring update (trigger activated)
    k8s-master: intel-microcode: microcode will be updated at next boot
    k8s-master: Setting up libpackagekit-glib2-18:amd64 (1.2.5-2ubuntu3) ...
    k8s-master: Setting up amd64-microcode (3.20191218.1ubuntu2.3) ...
    k8s-master: update-initramfs: deferring update (trigger activated)
    k8s-master: amd64-microcode: microcode will be updated at next boot
    k8s-master: Setting up libldap-common (2.5.18+dfsg-0ubuntu0.22.04.2) ...
    k8s-master: Setting up libldap-2.5-0:amd64 (2.5.18+dfsg-0ubuntu0.22.04.2) ...
    k8s-master: Setting up xxd (2:8.2.3995-1ubuntu2.21) ...
    k8s-master: Setting up apparmor (3.0.4-2ubuntu2.4) ...
    k8s-master: Reloading AppArmor profiles
    k8s-master: Skipping profile in /etc/apparmor.d/disable: usr.sbin.rsyslogd
    k8s-master: Setting up gir1.2-packagekitglib-1.0 (1.2.5-2ubuntu3) ...
    k8s-master: Setting up libglib2.0-data (2.72.4-0ubuntu2.4) ...
    k8s-master: Setting up vim-common (2:8.2.3995-1ubuntu2.21) ...
    k8s-master: Setting up busybox-static (1:1.30.1-7ubuntu3.1) ...
    k8s-master: Setting up libpcap0.8:amd64 (1.10.1-4ubuntu1.22.04.1) ...
    k8s-master: Setting up libss2:amd64 (1.46.5-2ubuntu1.2) ...
    k8s-master: Setting up libpython3.10-minimal:amd64 (3.10.12-1~22.04.7) ...
    k8s-master: Setting up busybox-initramfs (1:1.30.1-7ubuntu3.1) ...
    k8s-master: Setting up logsave (1.46.5-2ubuntu1.2) ...
    k8s-master: Setting up nano (6.2-1ubuntu0.1) ...
    k8s-master: Setting up python-apt-common (2.4.0ubuntu4) ...
    k8s-master: Setting up libmm-glib0:amd64 (1.20.0-1~ubuntu22.04.4) ...
    k8s-master: Setting up modemmanager (1.20.0-1~ubuntu22.04.4) ...
    k8s-master: Setting up dmidecode (3.3-3ubuntu0.2) ...
    k8s-master: Setting up vim-runtime (2:8.2.3995-1ubuntu2.21) ...
    k8s-master: Setting up openssl (3.0.2-0ubuntu1.18) ...
    k8s-master: Setting up libmodule-scandeps-perl (1.31-1ubuntu0.1) ...
    k8s-master: Setting up libgstreamer1.0-0:amd64 (1.20.3-0ubuntu1.1) ...
    k8s-master: Setcap worked! gst-ptp-helper is not suid!
    k8s-master: Setting up snapd (2.66.1+22.04) ...
    k8s-master: Installing new version of config file /etc/apparmor.d/usr.lib.snapd.snap-confine.real ...
    k8s-master: snapd.failure.service is a disabled or a static unit not running, not starting it.
    k8s-master: snapd.snap-repair.service is a disabled or a static unit not running, not starting it.
    k8s-master: Setting up needrestart (3.5-5ubuntu2.4) ...
    k8s-master: Setting up libglib2.0-bin (2.72.4-0ubuntu2.4) ...
    k8s-master: Setting up e2fsprogs (1.46.5-2ubuntu1.2) ...
    k8s-master: update-initramfs: deferring update (trigger activated)
    k8s-master: e2scrub_all.service is a disabled or a static unit not running, not starting it.
    k8s-master: Setting up libcurl3-gnutls:amd64 (7.81.0-1ubuntu1.20) ...
    k8s-master: Setting up vim-tiny (2:8.2.3995-1ubuntu2.21) ...
    k8s-master: Setting up python3.10-minimal (3.10.12-1~22.04.7) ...
    k8s-master: Setting up libpython3.10-stdlib:amd64 (3.10.12-1~22.04.7) ...
    k8s-master: Setting up packagekit (1.2.5-2ubuntu3) ...
    k8s-master: Setting up libpython3-stdlib:amd64 (3.10.6-1~22.04.1) ...
    k8s-master: Setting up packagekit-tools (1.2.5-2ubuntu3) ...
    k8s-master: Setting up libpython3.10:amd64 (3.10.12-1~22.04.7) ...
    k8s-master: Setting up vim (2:8.2.3995-1ubuntu2.21) ...
    k8s-master: Setting up python3.10 (3.10.12-1~22.04.7) ...
    k8s-master: Setting up python3 (3.10.6-1~22.04.1) ...
    k8s-master: running python rtupdate hooks for python3.10...
    k8s-master: running python post-rtupdate hooks for python3.10...
    k8s-master: Setting up python3-packaging (21.3-1) ...
    k8s-master: Setting up python3-configobj (5.0.6-5ubuntu0.1) ...
    k8s-master: Setting up python3-twisted (22.1.0-2ubuntu2.6) ...
    k8s-master: Setting up sosreport (4.7.2-0ubuntu1~22.04.2) ...
    k8s-master: Setting up python3-urllib3 (1.26.5-1~exp1ubuntu0.2) ...
    k8s-master: Setting up python3-pkg-resources (59.6.0-1.2ubuntu0.22.04.2) ...
    k8s-master: Setting up cloud-init (24.4-0ubuntu1~22.04.1) ...
    k8s-master: Installing new version of config file /etc/cloud/cloud.cfg ...
    k8s-master: Installing new version of config file /etc/cloud/templates/sources.list.ubuntu.deb822.tmpl ...
    k8s-master: Setting up python3-setuptools (59.6.0-1.2ubuntu0.22.04.2) ...
    k8s-master: Setting up python3-problem-report (2.20.11-0ubuntu82.6) ...
    k8s-master: Setting up python3-apt (2.4.0ubuntu4) ...
    k8s-master: Setting up python3-apport (2.20.11-0ubuntu82.6) ...
    k8s-master: Setting up ubuntu-pro-client (34~22.04) ...
    k8s-master: Installing new version of config file /etc/apparmor.d/ubuntu_pro_apt_news ...
    k8s-master: Installing new version of config file /etc/apt/apt.conf.d/20apt-esm-hook.conf ...
    k8s-master: Setting up ubuntu-pro-client-l10n (34~22.04) ...
    k8s-master: Setting up apport (2.20.11-0ubuntu82.6) ...
    k8s-master: apport-autoreport.service is a disabled or a static unit, not starting it.
    k8s-master: Setting up ubuntu-advantage-tools (34~22.04) ...
    k8s-master: Setting up ubuntu-minimal (1.481.4) ...
    k8s-master: Setting up linux-image-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: I: /boot/vmlinuz is now a symlink to vmlinuz-5.15.0-130-generic
    k8s-master: I: /boot/initrd.img is now a symlink to initrd.img-5.15.0-130-generic
    k8s-master: Setting up linux-modules-extra-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: Setting up linux-modules-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: Setting up linux-image-generic (5.15.0.130.128) ...
    k8s-master: Processing triggers for initramfs-tools (0.140ubuntu13.4) ...
    k8s-master: update-initramfs: Generating /boot/initrd.img-5.15.0-116-generic
    k8s-master: find: ‘/var/tmp/mkinitramfs_wLIfmW/lib/firmware’: No such file or directory
    k8s-master: Processing triggers for libc-bin (2.35-0ubuntu3.8) ...
    k8s-master: Processing triggers for rsyslog (8.2112.0-2ubuntu2.2) ...
    k8s-master: Processing triggers for man-db (2.10.2-1) ...
    k8s-master: Processing triggers for plymouth-theme-ubuntu-text (0.9.5+git20211018-1ubuntu3) ...
    k8s-master: update-initramfs: deferring update (trigger activated)
    k8s-master: Processing triggers for dbus (1.12.20-2ubuntu4.1) ...
    k8s-master: Processing triggers for install-info (6.8-4build1) ...
    k8s-master: Processing triggers for linux-image-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: /etc/kernel/postinst.d/dkms:
    k8s-master: dkms: WARNING: Linux headers are missing, which may explain the above failures.
    k8s-master:       please install the linux-headers-5.15.0-130-generic package to fix this.
    k8s-master: /etc/kernel/postinst.d/initramfs-tools:
    k8s-master: update-initramfs: Generating /boot/initrd.img-5.15.0-130-generic
    k8s-master: find: ‘/var/tmp/mkinitramfs_WD2AZl/lib/firmware’: No such file or directory
    k8s-master: /etc/kernel/postinst.d/zz-update-grub:
    k8s-master: Sourcing file `/etc/default/grub'
    k8s-master: Sourcing file `/etc/default/grub.d/init-select.cfg'
    k8s-master: Generating grub configuration file ...
    k8s-master: Found linux image: /boot/vmlinuz-5.15.0-130-generic
    k8s-master: Found initrd image: /boot/initrd.img-5.15.0-130-generic
    k8s-master: Found linux image: /boot/vmlinuz-5.15.0-116-generic
    k8s-master: Found initrd image: /boot/initrd.img-5.15.0-116-generic
    k8s-master: Warning: os-prober will not be executed to detect other bootable partitions.
    k8s-master: Systems on them will not be added to the GRUB boot configuration.
    k8s-master: Check GRUB_DISABLE_OS_PROBER documentation entry.
    k8s-master: done
    k8s-master: Processing triggers for initramfs-tools (0.140ubuntu13.4) ...
    k8s-master: update-initramfs: Generating /boot/initrd.img-5.15.0-130-generic
    k8s-master: find: ‘/var/tmp/mkinitramfs_EjQXsB/lib/firmware’: No such file or directory
    k8s-master: 
    k8s-master: Pending kernel upgrade!
    k8s-master:
    k8s-master: Running kernel version:
    k8s-master:   5.15.0-116-generic
    k8s-master:
    k8s-master: Diagnostics:
    k8s-master:   The currently running kernel version is not the expected kernel version 5.15.0-130-generic.
    k8s-master:
    k8s-master: Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting. [Return]
    k8s-master: 
    k8s-master: Services to be restarted:
    k8s-master:  systemctl restart irqbalance.service
    k8s-master:  systemctl restart polkit.service
    k8s-master:  systemctl restart rpcbind.service
    k8s-master:  systemctl restart ssh.service
    k8s-master:  systemctl restart systemd-journald.service
    k8s-master:  /etc/needrestart/restart.d/systemd-manager
    k8s-master:  systemctl restart systemd-networkd.service
    k8s-master:  systemctl restart systemd-resolved.service
    k8s-master:  systemctl restart systemd-udevd.service
    k8s-master:  systemctl restart udisks2.service
    k8s-master: 
    k8s-master: Service restarts being deferred:
    k8s-master:  /etc/needrestart/restart.d/dbus.service
    k8s-master:  systemctl restart networkd-dispatcher.service
    k8s-master:  systemctl restart systemd-logind.service
    k8s-master:  systemctl restart user@1000.service
    k8s-master:
    k8s-master: No containers need to be restarted.
    k8s-master: 
    k8s-master: No user sessions are running outdated binaries.
    k8s-master:
    k8s-master: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    k8s-master: grep: /etc/sysctl.conf  : No such file or directory
    k8s-master: net.bridge.bridge-nf-call-iptables = 1
    k8s-master: Rules updated
    k8s-master: Rules updated (v6)
    k8s-master: Rules updated
    k8s-master: Rules updated (v6)
    k8s-master: Rules updated
    k8s-master: Rules updated (v6)
    k8s-master: Rules updated
    k8s-master: Rules updated (v6)
    k8s-master: Rules updated
    k8s-master: Rules updated (v6)
    k8s-master: Rules updated
    k8s-master: Rules updated (v6)
    k8s-master: Rules updated
    k8s-master: Rules updated (v6)
    k8s-master: Rules updated
    k8s-master: Rules updated (v6)
    k8s-master: Rules updated
    k8s-master: Rules updated (v6)
    k8s-master: Rules updated
    k8s-master: Rules updated (v6)
    k8s-master: Rules updated
    k8s-master: Rules updated (v6)
    k8s-master: Skipping adding existing rule
    k8s-master: Skipping adding existing rule (v6)
==> k8s-master: Running provisioner: shell...
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-35872-eliznm.sh
    k8s-master: 
    k8s-master: WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
    k8s-master:
    k8s-master: Reading package lists...
    k8s-master: Building dependency tree...
    k8s-master: Reading state information...
    k8s-master: The following additional packages will be installed:
    k8s-master:   runc
    k8s-master: The following NEW packages will be installed:
    k8s-master:   containerd runc
    k8s-master: 0 upgraded, 2 newly installed, 0 to remove and 3 not upgraded.
    k8s-master: Need to get 46.2 MB of archives.
    k8s-master: After this operation, 175 MB of additional disk space will be used.
    k8s-master: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 runc amd64 1.1.12-0ubuntu2~22.04.1 [8,405 kB]
    k8s-master: Get:2 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 containerd amd64 1.7.12-0ubuntu2~22.04.1 [37.8 MB]
    k8s-master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-master: Fetched 46.2 MB in 4s (10.5 MB/s)
    k8s-master: Selecting previously unselected package runc.
(Reading database ... 52603 files and directories currently installed.)
    k8s-master: Preparing to unpack .../runc_1.1.12-0ubuntu2~22.04.1_amd64.deb ...
    k8s-master: Unpacking runc (1.1.12-0ubuntu2~22.04.1) ...
    k8s-master: Selecting previously unselected package containerd.
    k8s-master: Preparing to unpack .../containerd_1.7.12-0ubuntu2~22.04.1_amd64.deb ...
    k8s-master: Unpacking containerd (1.7.12-0ubuntu2~22.04.1) ...
    k8s-master: Setting up runc (1.1.12-0ubuntu2~22.04.1) ...
    k8s-master: Setting up containerd (1.7.12-0ubuntu2~22.04.1) ...
    k8s-master: Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /lib/systemd/system/containerd.service.
    k8s-master: Processing triggers for man-db (2.10.2-1) ...
    k8s-master: 
    k8s-master: Pending kernel upgrade!
    k8s-master:
    k8s-master: Running kernel version:
    k8s-master:   5.15.0-116-generic
    k8s-master:
    k8s-master: Diagnostics:
    k8s-master:   The currently running kernel version is not the expected kernel version 5.15.0-130-generic.
    k8s-master:
    k8s-master: Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting. [Return]
    k8s-master: 
    k8s-master: Services to be restarted:
    k8s-master:  systemctl restart irqbalance.service
    k8s-master:  systemctl restart polkit.service
    k8s-master:  systemctl restart rpcbind.service
    k8s-master:  systemctl restart ssh.service
    k8s-master:  systemctl restart systemd-journald.service
    k8s-master:  /etc/needrestart/restart.d/systemd-manager
    k8s-master:  systemctl restart systemd-networkd.service
    k8s-master:  systemctl restart systemd-resolved.service
    k8s-master:  systemctl restart systemd-udevd.service
    k8s-master:  systemctl restart udisks2.service
    k8s-master: 
    k8s-master: Service restarts being deferred:
    k8s-master:  /etc/needrestart/restart.d/dbus.service
    k8s-master:  systemctl restart networkd-dispatcher.service
    k8s-master:  systemctl restart systemd-logind.service
    k8s-master:  systemctl restart user@1000.service
    k8s-master:
    k8s-master: No containers need to be restarted.
    k8s-master:
    k8s-master: No user sessions are running outdated binaries.
    k8s-master:
    k8s-master: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    k8s-master: disabled_plugins = []
    k8s-master: imports = []
    k8s-master: oom_score = 0
    k8s-master: plugin_dir = ""
    k8s-master: required_plugins = []
    k8s-master: root = "/var/lib/containerd"
    k8s-master: state = "/run/containerd"
    k8s-master: temp = ""
    k8s-master: version = 2
    k8s-master:
    k8s-master: [cgroup]
    k8s-master:   path = ""
    k8s-master:
    k8s-master: [debug]
    k8s-master:   address = ""
    k8s-master:   format = ""
    k8s-master:   gid = 0
    k8s-master:   level = ""
    k8s-master:   uid = 0
    k8s-master:
    k8s-master: [grpc]
    k8s-master:   address = "/run/containerd/containerd.sock"
    k8s-master:   gid = 0
    k8s-master:   max_recv_message_size = 16777216
    k8s-master:   max_send_message_size = 16777216
    k8s-master:   tcp_address = ""
    k8s-master:   tcp_tls_ca = ""
    k8s-master:   tcp_tls_cert = ""
    k8s-master:   tcp_tls_key = ""
    k8s-master:   uid = 0
    k8s-master:
    k8s-master: [metrics]
    k8s-master:   address = ""
    k8s-master:   grpc_histogram = false
    k8s-master:
    k8s-master: [plugins]
    k8s-master: 
    k8s-master:   [plugins."io.containerd.gc.v1.scheduler"]
    k8s-master:     deletion_threshold = 0
    k8s-master:     mutation_threshold = 100
    k8s-master:     pause_threshold = 0.02
    k8s-master:     schedule_delay = "0s"
    k8s-master:     startup_delay = "100ms"
    k8s-master:
    k8s-master:   [plugins."io.containerd.grpc.v1.cri"]
    k8s-master:     cdi_spec_dirs = ["/etc/cdi", "/var/run/cdi"]
    k8s-master:     device_ownership_from_security_context = false
    k8s-master:     disable_apparmor = false
    k8s-master:     disable_cgroup = false
    k8s-master:     disable_hugetlb_controller = true
    k8s-master:     disable_proc_mount = false
    k8s-master:     disable_tcp_service = true
    k8s-master:     drain_exec_sync_io_timeout = "0s"
    k8s-master:     enable_cdi = false
    k8s-master:     enable_selinux = false
    k8s-master:     enable_tls_streaming = false
    k8s-master:     enable_unprivileged_icmp = false
    k8s-master:     enable_unprivileged_ports = false
    k8s-master:     ignore_image_defined_volumes = false
    k8s-master:     image_pull_progress_timeout = "5m0s"
    k8s-master:     max_concurrent_downloads = 3
    k8s-master:     max_container_log_line_size = 16384
    k8s-master:     netns_mounts_under_state_dir = false
    k8s-master:     restrict_oom_score_adj = false
    k8s-master:     sandbox_image = "registry.k8s.io/pause:3.8"
    k8s-master:     selinux_category_range = 1024
    k8s-master:     stats_collect_period = 10
    k8s-master:     stream_idle_timeout = "4h0m0s"
    k8s-master:     stream_server_address = "127.0.0.1"
    k8s-master:     stream_server_port = "0"
    k8s-master:     systemd_cgroup = false
    k8s-master:     tolerate_missing_hugetlb_controller = true
    k8s-master:     unset_seccomp_profile = ""
    k8s-master:
    k8s-master:     [plugins."io.containerd.grpc.v1.cri".cni]
    k8s-master:       bin_dir = "/opt/cni/bin"
    k8s-master:       conf_dir = "/etc/cni/net.d"
    k8s-master:       conf_template = ""
    k8s-master:       ip_pref = ""
    k8s-master:       max_conf_num = 1
    k8s-master:       setup_serially = false
    k8s-master:
    k8s-master:     [plugins."io.containerd.grpc.v1.cri".containerd]
    k8s-master:       default_runtime_name = "runc"
    k8s-master:       disable_snapshot_annotations = true
    k8s-master:       discard_unpacked_layers = false
    k8s-master:       ignore_blockio_not_enabled_errors = false
    k8s-master:       ignore_rdt_not_enabled_errors = false
    k8s-master:       no_pivot = false
    k8s-master:       snapshotter = "overlayfs"
    k8s-master:
    k8s-master:       [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
    k8s-master:         base_runtime_spec = ""
    k8s-master:         cni_conf_dir = ""
    k8s-master:         cni_max_conf_num = 0
    k8s-master:         container_annotations = []
    k8s-master:         pod_annotations = []
    k8s-master:         privileged_without_host_devices = false
    k8s-master:         privileged_without_host_devices_all_devices_allowed = false
    k8s-master:         runtime_engine = ""
    k8s-master:         runtime_path = ""
    k8s-master:         runtime_root = ""
    k8s-master:         runtime_type = ""
    k8s-master:         sandbox_mode = ""
    k8s-master:         snapshotter = ""
    k8s-master:
    k8s-master:         [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime.options]
    k8s-master:
    k8s-master:       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
    k8s-master:
    k8s-master:         [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    k8s-master:           base_runtime_spec = ""
    k8s-master:           cni_conf_dir = ""
    k8s-master:           cni_max_conf_num = 0
    k8s-master:           container_annotations = []
    k8s-master:           pod_annotations = []
    k8s-master:           privileged_without_host_devices = false
    k8s-master:           privileged_without_host_devices_all_devices_allowed = false
    k8s-master:           runtime_engine = ""
    k8s-master:           runtime_path = ""
    k8s-master:           runtime_root = ""
    k8s-master:           runtime_type = "io.containerd.runc.v2"
    k8s-master:           sandbox_mode = "podsandbox"
    k8s-master:           snapshotter = ""
    k8s-master:
    k8s-master:           [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    k8s-master:             BinaryName = ""
    k8s-master:             CriuImagePath = ""
    k8s-master:             CriuPath = ""
    k8s-master:             CriuWorkPath = ""
    k8s-master:             IoGid = 0
    k8s-master:             IoUid = 0
    k8s-master:             NoNewKeyring = false
    k8s-master:             NoPivotRoot = false
    k8s-master:             Root = ""
    k8s-master:             ShimCgroup = ""
    k8s-master:             SystemdCgroup = false
    k8s-master:
    k8s-master:       [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime]
    k8s-master:         base_runtime_spec = ""
    k8s-master:         cni_conf_dir = ""
    k8s-master:         cni_max_conf_num = 0
    k8s-master:         container_annotations = []
    k8s-master:         pod_annotations = []
    k8s-master:         privileged_without_host_devices = false
    k8s-master:         privileged_without_host_devices_all_devices_allowed = false
    k8s-master:         runtime_engine = ""
    k8s-master:         runtime_path = ""
    k8s-master:         runtime_root = ""
    k8s-master:         runtime_type = ""
    k8s-master:         sandbox_mode = ""
    k8s-master:         snapshotter = ""
    k8s-master:
    k8s-master:         [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime.options]
    k8s-master:
    k8s-master:     [plugins."io.containerd.grpc.v1.cri".image_decryption]
    k8s-master:       key_model = "node"
    k8s-master:
    k8s-master:     [plugins."io.containerd.grpc.v1.cri".registry]
    k8s-master:       config_path = ""
    k8s-master: 
    k8s-master:       [plugins."io.containerd.grpc.v1.cri".registry.auths]
    k8s-master:
    k8s-master:       [plugins."io.containerd.grpc.v1.cri".registry.configs]
    k8s-master:
    k8s-master:       [plugins."io.containerd.grpc.v1.cri".registry.headers]
    k8s-master:
    k8s-master:       [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
    k8s-master:
    k8s-master:     [plugins."io.containerd.grpc.v1.cri".x509_key_pair_streaming]
    k8s-master:       tls_cert_file = ""
    k8s-master:       tls_key_file = ""
    k8s-master:
    k8s-master:   [plugins."io.containerd.internal.v1.opt"]
    k8s-master:     path = "/opt/containerd"
    k8s-master:
    k8s-master:   [plugins."io.containerd.internal.v1.restart"]
    k8s-master:     interval = "10s"
    k8s-master:
    k8s-master:   [plugins."io.containerd.internal.v1.tracing"]
    k8s-master:     sampling_ratio = 1.0
    k8s-master:     service_name = "containerd"
    k8s-master:
    k8s-master:   [plugins."io.containerd.metadata.v1.bolt"]
    k8s-master:     content_sharing_policy = "shared"
    k8s-master:
    k8s-master:   [plugins."io.containerd.monitor.v1.cgroups"]
    k8s-master:     no_prometheus = false
    k8s-master:
    k8s-master:   [plugins."io.containerd.nri.v1.nri"]
    k8s-master:     disable = true
    k8s-master:     disable_connections = false
    k8s-master:     plugin_config_path = "/etc/nri/conf.d"
    k8s-master:     plugin_path = "/opt/nri/plugins"
    k8s-master:     plugin_registration_timeout = "5s"
    k8s-master:     plugin_request_timeout = "2s"
    k8s-master:     socket_path = "/var/run/nri/nri.sock"
    k8s-master:
    k8s-master:   [plugins."io.containerd.runtime.v1.linux"]
    k8s-master:     no_shim = false
    k8s-master:     runtime = "runc"
    k8s-master:     runtime_root = ""
    k8s-master:     shim = "containerd-shim"
    k8s-master:     shim_debug = false
    k8s-master: 
    k8s-master:   [plugins."io.containerd.runtime.v2.task"]
    k8s-master:     platforms = ["linux/amd64"]
    k8s-master:     sched_core = false
    k8s-master:
    k8s-master:   [plugins."io.containerd.service.v1.diff-service"]
    k8s-master:     default = ["walking"]
    k8s-master:
    k8s-master:   [plugins."io.containerd.service.v1.tasks-service"]
    k8s-master:     blockio_config_file = ""
    k8s-master:     rdt_config_file = ""
    k8s-master:
    k8s-master:   [plugins."io.containerd.snapshotter.v1.aufs"]
    k8s-master:     root_path = ""
    k8s-master:
    k8s-master:   [plugins."io.containerd.snapshotter.v1.blockfile"]
    k8s-master:     fs_type = ""
    k8s-master:     mount_options = []
    k8s-master:     root_path = ""
    k8s-master:     scratch_file = ""
    k8s-master:
    k8s-master:   [plugins."io.containerd.snapshotter.v1.btrfs"]
    k8s-master:     root_path = ""
    k8s-master:
    k8s-master:   [plugins."io.containerd.snapshotter.v1.devmapper"]
    k8s-master:     async_remove = false
    k8s-master:     base_image_size = ""
    k8s-master:     discard_blocks = false
    k8s-master:     fs_options = ""
    k8s-master:     fs_type = ""
    k8s-master:     pool_name = ""
    k8s-master:     root_path = ""
    k8s-master:
    k8s-master:   [plugins."io.containerd.snapshotter.v1.native"]
    k8s-master:     root_path = ""
    k8s-master:
    k8s-master:   [plugins."io.containerd.snapshotter.v1.overlayfs"]
    k8s-master:     mount_options = []
    k8s-master:     root_path = ""
    k8s-master:     sync_remove = false
    k8s-master:     upperdir_label = false
    k8s-master:
    k8s-master:   [plugins."io.containerd.snapshotter.v1.zfs"]
    k8s-master:     root_path = ""
    k8s-master:
    k8s-master:   [plugins."io.containerd.tracing.processor.v1.otlp"]
    k8s-master:     endpoint = ""
    k8s-master:     insecure = false
    k8s-master:     protocol = ""
    k8s-master:
    k8s-master:   [plugins."io.containerd.transfer.v1.local"]
    k8s-master:     config_path = ""
    k8s-master:     max_concurrent_downloads = 3
    k8s-master:     max_concurrent_uploaded_layers = 3
    k8s-master:
    k8s-master:     [[plugins."io.containerd.transfer.v1.local".unpack_config]]
    k8s-master:       differ = ""
    k8s-master:       platform = "linux/amd64"
    k8s-master:       snapshotter = "overlayfs"
    k8s-master:
    k8s-master: [proxy_plugins]
    k8s-master: 
    k8s-master: [stream_processors]
    k8s-master:
    k8s-master:   [stream_processors."io.containerd.ocicrypt.decoder.v1.tar"]
    k8s-master:     accepts = ["application/vnd.oci.image.layer.v1.tar+encrypted"]
    k8s-master:     args = ["--decryption-keys-path", "/etc/containerd/ocicrypt/keys"]
    k8s-master:     env = ["OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf"]
    k8s-master:     path = "ctd-decoder"
    k8s-master:     returns = "application/vnd.oci.image.layer.v1.tar"
    k8s-master:
    k8s-master:   [stream_processors."io.containerd.ocicrypt.decoder.v1.tar.gzip"]
    k8s-master:     accepts = ["application/vnd.oci.image.layer.v1.tar+gzip+encrypted"]
    k8s-master:     args = ["--decryption-keys-path", "/etc/containerd/ocicrypt/keys"]
    k8s-master:     env = ["OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf"]
    k8s-master:     path = "ctd-decoder"
    k8s-master:     returns = "application/vnd.oci.image.layer.v1.tar+gzip"
    k8s-master:
    k8s-master: [timeouts]
    k8s-master:   "io.containerd.timeout.bolt.open" = "0s"
    k8s-master:   "io.containerd.timeout.metrics.shimstats" = "2s"
    k8s-master:   "io.containerd.timeout.shim.cleanup" = "5s"
    k8s-master:   "io.containerd.timeout.shim.load" = "5s"
    k8s-master:   "io.containerd.timeout.shim.shutdown" = "3s"
    k8s-master:   "io.containerd.timeout.task.state" = "2s"
    k8s-master:
    k8s-master: [ttrpc]
    k8s-master:   address = ""
    k8s-master:   gid = 0
    k8s-master:   uid = 0
    k8s-master: ● containerd.service - containerd container runtime
    k8s-master:      Loaded: loaded (/lib/systemd/system/containerd.service; enabled; vendor preset: enabled)
    k8s-master:      Active: active (running) since Wed 2025-01-08 08:36:09 UTC; 14ms ago
    k8s-master:        Docs: https://containerd.io
    k8s-master:     Process: 49732 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
    k8s-master:    Main PID: 49733 (containerd)
    k8s-master:       Tasks: 8
    k8s-master:      Memory: 13.7M
    k8s-master:         CPU: 111ms
    k8s-master:      CGroup: /system.slice/containerd.service
    k8s-master:              └─49733 /usr/bin/containerd
    k8s-master:
    k8s-master: Jan 08 08:36:09 k8s-master containerd[49733]: time="2025-01-08T08:36:09.511134187Z" level=info msg=serving... address=/run/containerd/containerd.sock.ttrpc
    k8s-master: Jan 08 08:36:09 k8s-master containerd[49733]: time="2025-01-08T08:36:09.511492971Z" level=info msg=serving... address=/run/containerd/containerd.sock    
    k8s-master: Jan 08 08:36:09 k8s-master containerd[49733]: time="2025-01-08T08:36:09.511305138Z" level=info msg="Start subscribing containerd event"
    k8s-master: Jan 08 08:36:09 k8s-master containerd[49733]: time="2025-01-08T08:36:09.512028904Z" level=info msg="Start recovering state"
    k8s-master: Jan 08 08:36:09 k8s-master containerd[49733]: time="2025-01-08T08:36:09.512087772Z" level=info msg="Start event monitor"
    k8s-master: Jan 08 08:36:09 k8s-master containerd[49733]: time="2025-01-08T08:36:09.512097267Z" level=info msg="Start snapshots syncer"
    k8s-master: Jan 08 08:36:09 k8s-master containerd[49733]: time="2025-01-08T08:36:09.512105526Z" level=info msg="Start cni network conf syncer for default"
    k8s-master: Jan 08 08:36:09 k8s-master containerd[49733]: time="2025-01-08T08:36:09.512116793Z" level=info msg="Start streaming server"
    k8s-master: Jan 08 08:36:09 k8s-master systemd[1]: Started containerd container runtime.
    k8s-master: Jan 08 08:36:09 k8s-master containerd[49733]: time="2025-01-08T08:36:09.524148961Z" level=info msg="containerd successfully booted in 0.057848s"
==> k8s-master: Running provisioner: shell...
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-35872-pensfy.sh
    k8s-master: Hit:1 http://security.ubuntu.com/ubuntu jammy-security InRelease
    k8s-master: Hit:2 http://us.archive.ubuntu.com/ubuntu jammy InRelease
    k8s-master: Hit:3 http://us.archive.ubuntu.com/ubuntu jammy-updates InRelease
    k8s-master: Hit:4 http://us.archive.ubuntu.com/ubuntu jammy-backports InRelease
    k8s-master: Reading package lists...
    k8s-master: Reading package lists...
    k8s-master: Building dependency tree...
    k8s-master: Reading state information...
    k8s-master: ca-certificates is already the newest version (20240203~22.04.1).
    k8s-master: ca-certificates set to manually installed.
    k8s-master: curl is already the newest version (7.81.0-1ubuntu1.20).
    k8s-master: gpg is already the newest version (2.2.27-3ubuntu2.1).
    k8s-master: gpg set to manually installed.
    k8s-master: apt-transport-https is already the newest version (2.4.13).
    k8s-master: 0 upgraded, 0 newly installed, 0 to remove and 3 not upgraded.
    k8s-master: Directory exists
    k8s-master: deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /
    k8s-master: Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  InRelease [1,186 B]
    k8s-master: Hit:2 http://security.ubuntu.com/ubuntu jammy-security InRelease
    k8s-master: Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  Packages [2,731 B]
    k8s-master: Hit:4 http://us.archive.ubuntu.com/ubuntu jammy InRelease
    k8s-master: Hit:5 http://us.archive.ubuntu.com/ubuntu jammy-updates InRelease
    k8s-master: Hit:6 http://us.archive.ubuntu.com/ubuntu jammy-backports InRelease
    k8s-master: Fetched 3,917 B in 1s (3,548 B/s)
    k8s-master: Reading package lists...
    k8s-master: Reading package lists...
    k8s-master: Building dependency tree...
    k8s-master: Reading state information...
    k8s-master: The following additional packages will be installed:
    k8s-master:   conntrack cri-tools kubernetes-cni
    k8s-master: The following NEW packages will be installed:
    k8s-master:   conntrack cri-tools kubeadm kubectl kubelet kubernetes-cni
    k8s-master: 0 upgraded, 6 newly installed, 0 to remove and 3 not upgraded.
    k8s-master: Need to get 92.7 MB of archives.
    k8s-master: After this operation, 338 MB of additional disk space will be used.
    k8s-master: Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  cri-tools 1.32.0-1.1 [16.3 MB]
    k8s-master: Get:2 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 conntrack amd64 1:1.4.6-2build2 [33.5 kB]
    k8s-master: Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  kubeadm 1.32.0-1.1 [12.2 MB]
    k8s-master: Get:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  kubectl 1.32.0-1.1 [11.3 MB]
    k8s-master: Get:5 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  kubernetes-cni 1.6.0-1.1 [37.8 MB]
    k8s-master: Get:6 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  kubelet 1.32.0-1.1 [15.2 MB]
    k8s-master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-master: Fetched 92.7 MB in 3s (36.1 MB/s)
    k8s-master: Selecting previously unselected package conntrack.
(Reading database ... 52667 files and directories currently installed.)
    k8s-master: Preparing to unpack .../0-conntrack_1%3a1.4.6-2build2_amd64.deb ...
    k8s-master: Unpacking conntrack (1:1.4.6-2build2) ...
    k8s-master: Selecting previously unselected package cri-tools.
    k8s-master: Preparing to unpack .../1-cri-tools_1.32.0-1.1_amd64.deb ...
    k8s-master: Unpacking cri-tools (1.32.0-1.1) ...
    k8s-master: Selecting previously unselected package kubeadm.
    k8s-master: Preparing to unpack .../2-kubeadm_1.32.0-1.1_amd64.deb ...
    k8s-master: Unpacking kubeadm (1.32.0-1.1) ...
    k8s-master: Selecting previously unselected package kubectl.
    k8s-master: Preparing to unpack .../3-kubectl_1.32.0-1.1_amd64.deb ...
    k8s-master: Unpacking kubectl (1.32.0-1.1) ...
    k8s-master: Selecting previously unselected package kubernetes-cni.
    k8s-master: Preparing to unpack .../4-kubernetes-cni_1.6.0-1.1_amd64.deb ...
    k8s-master: Unpacking kubernetes-cni (1.6.0-1.1) ...
    k8s-master: Selecting previously unselected package kubelet.
    k8s-master: Preparing to unpack .../5-kubelet_1.32.0-1.1_amd64.deb ...
    k8s-master: Unpacking kubelet (1.32.0-1.1) ...
    k8s-master: Setting up conntrack (1:1.4.6-2build2) ...
    k8s-master: Setting up kubectl (1.32.0-1.1) ...
    k8s-master: Setting up cri-tools (1.32.0-1.1) ...
    k8s-master: Setting up kubernetes-cni (1.6.0-1.1) ...
    k8s-master: Setting up kubeadm (1.32.0-1.1) ...
    k8s-master: Setting up kubelet (1.32.0-1.1) ...
    k8s-master: Processing triggers for man-db (2.10.2-1) ...
    k8s-master: 
    k8s-master: Pending kernel upgrade!
    k8s-master:
    k8s-master: Running kernel version:
    k8s-master:   5.15.0-116-generic
    k8s-master:
    k8s-master: Diagnostics:
    k8s-master:   The currently running kernel version is not the expected kernel version 5.15.0-130-generic.
    k8s-master:
    k8s-master: Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting. [Return]
    k8s-master: 
    k8s-master: Services to be restarted:
    k8s-master:  systemctl restart irqbalance.service
    k8s-master:  systemctl restart polkit.service
    k8s-master:  systemctl restart rpcbind.service
    k8s-master:  systemctl restart ssh.service
    k8s-master:  systemctl restart systemd-journald.service
    k8s-master:  /etc/needrestart/restart.d/systemd-manager
    k8s-master:  systemctl restart systemd-networkd.service
    k8s-master:  systemctl restart systemd-resolved.service
    k8s-master:  systemctl restart systemd-udevd.service
    k8s-master:  systemctl restart udisks2.service
    k8s-master: 
    k8s-master: Service restarts being deferred:
    k8s-master:  /etc/needrestart/restart.d/dbus.service
    k8s-master:  systemctl restart networkd-dispatcher.service
    k8s-master:  systemctl restart systemd-logind.service
    k8s-master:  systemctl restart user@1000.service
    k8s-master:
    k8s-master: No containers need to be restarted.
    k8s-master:
    k8s-master: No user sessions are running outdated binaries.
    k8s-master:
    k8s-master: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    k8s-master: kubelet set on hold.
    k8s-master: kubeadm set on hold.
    k8s-master: kubectl set on hold.
    k8s-master: 
    k8s-master: WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
    k8s-master:
    k8s-master: Reading package lists...
    k8s-master: Building dependency tree...
    k8s-master: Reading state information...
    k8s-master: The following NEW packages will be installed:
    k8s-master:   containernetworking-plugins
    k8s-master: 0 upgraded, 1 newly installed, 0 to remove and 3 not upgraded.
    k8s-master: Need to get 6,806 kB of archives.
    k8s-master: After this operation, 46.2 MB of additional disk space will be used.
    k8s-master: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/universe amd64 containernetworking-plugins amd64 0.9.1+ds1-1ubuntu0.1 [6,806 kB]
    k8s-master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-master: Fetched 6,806 kB in 3s (2,501 kB/s)
    k8s-master: Selecting previously unselected package containernetworking-plugins.
(Reading database ... 52726 files and directories currently installed.)
    k8s-master: Preparing to unpack .../containernetworking-plugins_0.9.1+ds1-1ubuntu0.1_amd64.deb ...
    k8s-master: Unpacking containernetworking-plugins (0.9.1+ds1-1ubuntu0.1) ...
    k8s-master: Setting up containernetworking-plugins (0.9.1+ds1-1ubuntu0.1) ...
    k8s-master: 
    k8s-master: Pending kernel upgrade!
    k8s-master:
    k8s-master: Running kernel version:
    k8s-master:   5.15.0-116-generic
    k8s-master:
    k8s-master: Diagnostics:
    k8s-master:   The currently running kernel version is not the expected kernel version 5.15.0-130-generic.
    k8s-master:
    k8s-master: Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting. [Return]
    k8s-master:
    k8s-master: Services to be restarted:
    k8s-master:  systemctl restart irqbalance.service
    k8s-master:  systemctl restart polkit.service
    k8s-master:  systemctl restart rpcbind.service
    k8s-master:  systemctl restart ssh.service
    k8s-master:  systemctl restart systemd-journald.service
    k8s-master:  /etc/needrestart/restart.d/systemd-manager
    k8s-master:  systemctl restart systemd-networkd.service
    k8s-master:  systemctl restart systemd-resolved.service
    k8s-master:  systemctl restart systemd-udevd.service
    k8s-master:  systemctl restart udisks2.service
    k8s-master: 
    k8s-master: Service restarts being deferred:
    k8s-master:  /etc/needrestart/restart.d/dbus.service
    k8s-master:  systemctl restart networkd-dispatcher.service
    k8s-master:  systemctl restart systemd-logind.service
    k8s-master:  systemctl restart user@1000.service
    k8s-master:
    k8s-master: No containers need to be restarted.
    k8s-master:
    k8s-master: No user sessions are running outdated binaries.
    k8s-master:
    k8s-master: No VM guests are running outdated hypervisor (qemu) binaries on this host.
==> k8s-master: Running provisioner: shell...
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-35872-5jtq9l.sh
    k8s-master: Reading package lists...
    k8s-master: Building dependency tree...
    k8s-master: Reading state information...
    k8s-master: 0 upgraded, 0 newly installed, 0 to remove and 3 not upgraded.
    k8s-master: Reading package lists...
    k8s-master: Building dependency tree...
    k8s-master: Reading state information...
    k8s-master: The following packages were automatically installed and are no longer required:
    k8s-master:   amd64-microcode libdbus-glib-1-2 libevdev2 libimobiledevice6 libplist3
    k8s-master:   libupower-glib3 libusbmuxd6 thermald upower usbmuxd
    k8s-master: Use 'sudo apt autoremove' to remove them.
    k8s-master: The following additional packages will be installed:
    k8s-master:   linux-image-unsigned-5.15.0-130-generic
    k8s-master: Suggested packages:
    k8s-master:   fdutils linux-doc | linux-source-5.15.0 linux-tools
    k8s-master:   linux-headers-5.15.0-130-generic linux-modules-extra-5.15.0-130-generic
    k8s-master: The following packages will be REMOVED:
    k8s-master:   linux-image-5.15.0-130-generic* linux-image-generic*
    k8s-master:   linux-modules-extra-5.15.0-130-generic*
    k8s-master: The following NEW packages will be installed:
    k8s-master:   linux-image-unsigned-5.15.0-130-generic
    k8s-master: 0 upgraded, 1 newly installed, 3 to remove and 3 not upgraded.
    k8s-master: Need to get 11.8 MB of archives.
    k8s-master: After this operation, 352 MB disk space will be freed.
    k8s-master: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-image-unsigned-5.15.0-130-generic amd64 5.15.0-130.140 [11.8 MB]
    k8s-master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-master: Fetched 11.8 MB in 3s (3,975 kB/s)
(Reading database ... 52749 files and directories currently installed.)
    k8s-master: Removing linux-image-generic (5.15.0.130.128) ...
    k8s-master: Removing linux-modules-extra-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: dpkg: linux-image-5.15.0-130-generic: dependency problems, but removing anyway as you requested:
    k8s-master:  linux-modules-5.15.0-130-generic depends on linux-image-5.15.0-130-generic | linux-image-unsigned-5.15.0-130-generic; however:
    k8s-master:   Package linux-image-5.15.0-130-generic is to be removed.
    k8s-master:   Package linux-image-unsigned-5.15.0-130-generic is not installed.
    k8s-master:
    k8s-master: Removing linux-image-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: I: /boot/vmlinuz is now a symlink to vmlinuz-5.15.0-116-generic
    k8s-master: I: /boot/initrd.img is now a symlink to initrd.img-5.15.0-116-generic
    k8s-master: /etc/kernel/postrm.d/initramfs-tools:
    k8s-master: update-initramfs: Deleting /boot/initrd.img-5.15.0-130-generic
    k8s-master: /etc/kernel/postrm.d/zz-update-grub:
    k8s-master: Sourcing file `/etc/default/grub'
    k8s-master: Sourcing file `/etc/default/grub.d/init-select.cfg'
    k8s-master: Generating grub configuration file ...
    k8s-master: Found linux image: /boot/vmlinuz-5.15.0-116-generic
    k8s-master: Found initrd image: /boot/initrd.img-5.15.0-116-generic
    k8s-master: Warning: os-prober will not be executed to detect other bootable partitions.
    k8s-master: Systems on them will not be added to the GRUB boot configuration.
    k8s-master: Check GRUB_DISABLE_OS_PROBER documentation entry.
    k8s-master: done
    k8s-master: Selecting previously unselected package linux-image-unsigned-5.15.0-130-generic.
(Reading database ... 46835 files and directories currently installed.)
    k8s-master: Preparing to unpack .../linux-image-unsigned-5.15.0-130-generic_5.15.0-130.140_amd64.deb ...
    k8s-master: Unpacking linux-image-unsigned-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: Setting up linux-image-unsigned-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: I: /boot/vmlinuz is now a symlink to vmlinuz-5.15.0-130-generic
    k8s-master: I: /boot/initrd.img is now a symlink to initrd.img-5.15.0-130-generic
(Reading database ... 46838 files and directories currently installed.)
    k8s-master: Purging configuration files for linux-image-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: I: /boot/vmlinuz is now a symlink to vmlinuz-5.15.0-116-generic
    k8s-master: I: /boot/initrd.img is now a symlink to initrd.img-5.15.0-116-generic
    k8s-master: /var/lib/dpkg/info/linux-image-5.15.0-130-generic.postrm ... removing pending trigger
    k8s-master: rmdir: failed to remove '/lib/modules/5.15.0-130-generic': Directory not empty
    k8s-master: Purging configuration files for linux-modules-extra-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: Processing triggers for linux-image-unsigned-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: 
    k8s-master: Pending kernel upgrade!
    k8s-master:
    k8s-master: Running kernel version:
    k8s-master:   5.15.0-116-generic
    k8s-master:
    k8s-master: Diagnostics:
    k8s-master:   The currently running kernel version is not the expected kernel version 5.15.0-130-generic.
    k8s-master:
    k8s-master: Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting. [Return]
    k8s-master: 
    k8s-master: Services to be restarted:
    k8s-master:  systemctl restart irqbalance.service
    k8s-master:  systemctl restart polkit.service
    k8s-master:  systemctl restart rpcbind.service
    k8s-master:  systemctl restart ssh.service
    k8s-master:  systemctl restart systemd-journald.service
    k8s-master:  /etc/needrestart/restart.d/systemd-manager
    k8s-master:  systemctl restart systemd-networkd.service
    k8s-master:  systemctl restart systemd-resolved.service
    k8s-master:  systemctl restart systemd-udevd.service
    k8s-master:  systemctl restart udisks2.service
    k8s-master:
    k8s-master: Service restarts being deferred:
    k8s-master:  /etc/needrestart/restart.d/dbus.service
    k8s-master:  systemctl restart networkd-dispatcher.service
    k8s-master:  systemctl restart systemd-logind.service
    k8s-master:  systemctl restart user@1000.service
    k8s-master:
    k8s-master: No containers need to be restarted.
    k8s-master: 
    k8s-master: No user sessions are running outdated binaries.
    k8s-master:
    k8s-master: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    k8s-master: Vacuuming done, freed 0B of archived journals from /run/log/journal.
    k8s-master: Vacuuming done, freed 0B of archived journals from /var/log/journal/c37870b8dc4a46d685923d2c1c2b2f7e.
    k8s-master: Vacuuming done, freed 0B of archived journals from /var/log/journal.
==> k8s-master: Running provisioner: shell...
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-35872-1ibyg9.sh
    k8s-master: [init] Using Kubernetes version: v1.32.0
    k8s-master: [preflight] Running pre-flight checks
    k8s-master: error execution phase preflight: [preflight] Some fatal errors occurred:
    k8s-master:         [ERROR Mem]: the system RAM (957 MB) is less than the minimum 1700 MB
    k8s-master: [preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
    k8s-master: To see the stack trace of this error execute with --v=5 or higher
The SSH command responded with a non-zero exit status. Vagrant
assumes that this means the command failed. The output for this command
should be in the log above. Please read the output to determine what
went wrong.
╭─ pwsh     kubernetes-cluster    master ≡  ?4 ~9 -1   9m 20s 794ms⠀                                         default@ap-northeast-2  arn:aws:eks:ap-northeast-2:143719223348:cluster/sksh-argos-p-eks-ui-01    97    8,17:37 
╰─ 
```