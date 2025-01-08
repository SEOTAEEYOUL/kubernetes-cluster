# vagrant up

## 오류
### 오류 내용
```
PS > vagrant up
Vagrant failed to initialize at a very early stage:

There was an error loading a Vagrantfile. The file being loaded
and the error message are shown below. This is usually caused by
an invalid or undefined variable.

Path: C:/Users/____/.vagrant.d/gems/3.3.6/gems/dotenv-0.11.1/lib/dotenv.rb
Line number: 0
Message: undefined method `exists?'
PS > 
```

### 조치
- exists -> exist 로 수정
```
sudo sed -i -e 's/exists?/exist?/g' /root/.vagrant.d/gems/3.3.6/gems/dotenv-0.11.1/lib/dotenv.rb
```
```ruby
require 'dotenv/parser'
require 'dotenv/environment'

module Dotenv
  def self.load(*filenames)
    # with(*filenames) { |f| Environment.new(f).apply if File.exists?(f) }
    with(*filenames) { |f| Environment.new(f).apply if File.exist?(f) }
  end

  # same as `load`, but raises Errno::ENOENT if any files don't exist
  def self.load!(*filenames)
    with(*filenames) { |f| Environment.new(f).apply }
  end

  # same as `load`, but will override existing values in `ENV`
  def self.overload(*filenames)
    # with(*filenames) { |f| Environment.new(f).apply! if File.exists?(f) }
    with(*filenames) { |f| Environment.new(f).apply! if File.exist?(f) }
  end

protected

  def self.with(*filenames, &block)
    filenames << '.env' if filenames.empty?

    filenames.inject({}) do |hash, filename|
      filename = File.expand_path filename
      hash.merge(block.call(filename) || {})
    end
  end
end
```

```
module VagrantVbguest
  module Hosts
    class VirtualBox < Base

      def read_guest_additions_version
        # this way of checking for the GuestAdditionsVersion is taken from Vagrant's
        # `read_guest_additions_version` method introduced via
        # https://github.com/hashicorp/vagrant/commit/d8ff2cb5adca25d7eba2bdd334919770316c91be
        # for VirtualBox 4.2 and carries on for later versons until now
        # We are vendoring it here, since Vagrant uses it is only a fallback
        # for when `guestproperty` won't work. But `guestproperty` seems to be prone
        # to return incorrect values.
        if Gem::Requirement.new(">= 4.2").satisfied_by? Gem::Version.new(version)
          uuid = self.class.vm_id(vm)
          begin
            info = driver.execute("showvminfo", uuid, "--machinereadable", retryable: true)
            info.split("\n").each do |line|
              return $1.to_s if line =~ /^GuestAdditionsVersion="(.+?)"$/
            end
          rescue Vagrant::Errors::VBoxManageError => e
            if e.message =~ /Invalid command.*showvminfo/i
              vm.env.ui.warn("Cannot read GuestAdditionsVersion using 'showvminfo'")
              vm.env.ui.debug(e.message)
            else
              raise e
            end
          end
        end

        super
      end

      protected

        # Default web URI, where GuestAdditions iso file can be downloaded.
        #
        # @return [String] A URI template containing the versions placeholder.
        def web_path
          "https://download.virtualbox.org/virtualbox/%{version}/VBoxGuestAdditions_%{version}.iso"
        end


        # Finds GuestAdditions iso file on the host system.
        # Returns +nil+ if none found.
        #
        # @return [String] Absolute path to the local GuestAdditions iso file, or +nil+ if not found.
        def local_path
          media_manager_iso || guess_local_iso
        end

        # Kicks off +VagrantVbguest::Download+ to download the additions file
        # into a temp file.
        #
        # To remove the created tempfile call +cleanup+
        #
        # @param path [String] The path or URI to download
        #
        # @return [String] The path to the downloaded file
        def download(path)
          temp_path = File.join(@env.tmp_path, "VBoxGuestAdditions_#{version}.iso")
          @download = VagrantVbguest::Download.new(path, temp_path, :ui => @env.ui)
          @download.download!
          @download.destination
        end

      private

        # Helper method which queries the VirtualBox media manager
        # for the first existing path that looks like a
        # +VBoxGuestAdditions.iso+ file.
        #
        # @return [String] Absolute path to the local GuestAdditions iso file, or +nil+ if not found.
        def media_manager_iso
          driver.execute('list', 'dvds').scan(/^.+:\s+(.*VBoxGuestAdditions(?:_#{version})?\.iso)$/i).map { |path, _|
            path if File.exist?(path)
          }.compact.first
        end

        # Find the first GuestAdditions iso file which exists on the host system
        #
        # @return [String] Absolute path to the local GuestAdditions iso file, or +nil+ if not found.
        def guess_local_iso
          Array(platform_path).find do |path|
            # path && File.exists?(path)
            path && File.exist?(path)
          end
        end

        # Makes an educated guess where the GuestAdditions iso file
        # could be found on the host system depending on the OS.
        # Returns +nil+ if no the file is not in it's place.
        def platform_path
          [:linux, :darwin, :cygwin, :windows].each do |sys|
            return self.send("#{sys}_path") if Vagrant::Util::Platform.respond_to?("#{sys}?") && Vagrant::Util::Platform.send("#{sys}?")
          end
          nil
        end

        # Makes an educated guess where the GuestAdditions iso file
        # on linux based systems
        def linux_path
          paths = [
            "/usr/share/virtualbox/VBoxGuestAdditions.iso",
            "/usr/lib/virtualbox/additions/VBoxGuestAdditions.iso"
          ]
          paths.unshift(File.join(ENV['HOME'], '.VirtualBox', "VBoxGuestAdditions_#{version}.iso")) if ENV['HOME']
          paths
        end

        # Makes an educated guess where the GuestAdditions iso file
        # on Macs
        def darwin_path
          "/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"
        end

        # Makes an educated guess where the GuestAdditions iso file
        # on windows systems
        def windows_path
          if (p = ENV["VBOX_INSTALL_PATH"] || ENV["VBOX_MSI_INSTALL_PATH"]) && !p.empty?
            File.join(p, "VBoxGuestAdditions.iso")
          elsif (p = ENV["PROGRAM_FILES"] || ENV["ProgramW6432"] || ENV["PROGRAMFILES"]) && !p.empty?
            File.join(p, "/Oracle/VirtualBox/VBoxGuestAdditions.iso")
          end
        end
        alias_method :cygwin_path, :windows_path

        # overwrite the default version string to allow lagacy
        # '$VBOX_VERSION' as a placerholder
        def versionize(path)
          super(path.gsub('$VBOX_VERSION', version))
        end

    end
  end
end
```

## 출력 로그

### vagrant status
```
PS > vagrant status
Current machine states:

k8s-master                not created (virtualbox)
k8s-worker-1              not created (virtualbox)
k8s-worker-2              not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
PS > 
```

### vagrant up - 2025.01.27
- 1 master, 1 worker
```powershell
PS > vagrant up
Bringing machine 'k8s-master' up with 'virtualbox' provider...
Bringing machine 'k8s-worker-1' up with 'virtualbox' provider...
==> k8s-master: Importing base box 'bento/ubuntu-22.04'...
==> k8s-master: Matching MAC address for NAT networking...
==> k8s-master: Checking if box 'bento/ubuntu-22.04' version '202407.23.0' is up to date...
==> k8s-master: Setting the name of the VM: kubernetes-cluster_k8s-master_1736325708262_79843
==> k8s-master: Clearing any previously set network interfaces...
==> k8s-master: Preparing network interfaces based on configuration...
    k8s-master: Adapter 1: nat
    k8s-master: Adapter 2: intnet
==> k8s-master: Forwarding ports...
    k8s-master: 22 (guest) => 2222 (host) (adapter 1)
==> k8s-master: Running 'pre-boot' VM customizations...
==> k8s-master: Booting VM...
==> k8s-master: Waiting for machine to boot. This may take a few minutes...
    k8s-master: SSH address: 127.0.0.1:2222
    k8s-master: SSH username: vagrant
    k8s-master: SSH auth method: private key
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
    k8s-master: Warning: Connection reset. Retrying...
    k8s-master: Warning: Connection aborted. Retrying...
    k8s-master: Warning: Remote connection disconnect. Retrying...
==> k8s-master: Machine booted and ready!
==> k8s-master: Checking for guest additions in VM...
    k8s-master: The guest additions on this VM do not match the installed version of
    k8s-master: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-master: prevent things such as shared folders from working properly. If you see
    k8s-master: shared folder errors, please make sure the guest additions within the
    k8s-master: virtual machine match the version of VirtualBox you have installed on
    k8s-master: your host and reload your VM.
    k8s-master:
    k8s-master: Guest Additions Version: 6.0.0 r127566
    k8s-master: VirtualBox Version: 7.0
==> k8s-master: Setting hostname...
==> k8s-master: Configuring and enabling network interfaces...
==> k8s-master: Mounting shared folders...
    k8s-master: D:/workspace/kubernetes-cluster => /vagrant
==> k8s-master: Running provisioner: shell...
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-ydfbyv.sh
    k8s-master: nc: connect to 127.0.0.1 port 6443 (tcp) failed: Connection refused
    k8s-master: Hit:1 http://us.archive.ubuntu.com/ubuntu jammy InRelease
    k8s-master: Get:2 http://security.ubuntu.com/ubuntu jammy-security InRelease [129 kB]
    k8s-master: Get:3 http://us.archive.ubuntu.com/ubuntu jammy-updates InRelease [128 kB]
    k8s-master: Get:4 http://us.archive.ubuntu.com/ubuntu jammy-backports InRelease [127 kB]
    k8s-master: Get:5 http://security.ubuntu.com/ubuntu jammy-security/main amd64 Packages [2,036 kB]
    k8s-master: Get:6 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages [2,271 kB]
    k8s-master: Get:7 http://us.archive.ubuntu.com/ubuntu jammy-updates/main Translation-en [382 kB]
    k8s-master: Get:8 http://us.archive.ubuntu.com/ubuntu jammy-updates/restricted amd64 Packages [2,867 kB]
    k8s-master: Get:9 http://security.ubuntu.com/ubuntu jammy-security/main Translation-en [321 kB]
    k8s-master: Get:10 http://security.ubuntu.com/ubuntu jammy-security/restricted amd64 Packages [2,761 kB]
    k8s-master: Get:11 http://us.archive.ubuntu.com/ubuntu jammy-updates/restricted Translation-en [500 kB]
    k8s-master: Get:12 http://us.archive.ubuntu.com/ubuntu jammy-updates/universe amd64 Packages [1,181 kB]
    k8s-master: Get:13 http://security.ubuntu.com/ubuntu jammy-security/restricted Translation-en [482 kB]
    k8s-master: Get:14 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 Packages [958 kB]
    k8s-master: Get:15 http://security.ubuntu.com/ubuntu jammy-security/universe Translation-en [204 kB]
    k8s-master: Get:16 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 Packages [37.6 kB]
    k8s-master: Get:17 http://security.ubuntu.com/ubuntu jammy-security/multiverse Translation-en [8,260 B]
    k8s-master: Get:18 http://us.archive.ubuntu.com/ubuntu jammy-updates/universe Translation-en [288 kB]
    k8s-master: Get:19 http://us.archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 Packages [44.5 kB]
    k8s-master: Get:20 http://us.archive.ubuntu.com/ubuntu jammy-updates/multiverse Translation-en [11.5 kB]
    k8s-master: Get:21 http://us.archive.ubuntu.com/ubuntu jammy-backports/main amd64 Packages [67.7 kB]
    k8s-master: Get:22 http://us.archive.ubuntu.com/ubuntu jammy-backports/main Translation-en [11.1 kB]
    k8s-master: Get:23 http://us.archive.ubuntu.com/ubuntu jammy-backports/universe amd64 Packages [28.9 kB]
    k8s-master: Get:24 http://us.archive.ubuntu.com/ubuntu jammy-backports/universe Translation-en [16.5 kB]
    k8s-master: Fetched 14.9 MB in 6s (2,323 kB/s)
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
    k8s-master: Fetched 647 kB in 2s (315 kB/s)
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
    k8s-master: Fetched 1,203 kB in 2s (526 kB/s)
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
    k8s-master: Hit:1 http://security.ubuntu.com/ubuntu jammy-security InRelease
    k8s-master: Hit:2 http://us.archive.ubuntu.com/ubuntu jammy InRelease
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
    k8s-master: The following packages will be upgraded:
    k8s-master:   amd64-microcode apparmor apport apt apt-utils base-files bind9-dnsutils
    k8s-master:   bind9-host bind9-libs busybox-initramfs busybox-static cloud-init
    k8s-master:   distro-info-data dmidecode e2fsprogs gir1.2-packagekitglib-1.0
    k8s-master:   intel-microcode libapparmor1 libapt-pkg6.0 libarchive13 libcom-err2
    k8s-master:   libcurl3-gnutls libexpat1 libext2fs2 libglib2.0-0 libglib2.0-bin
    k8s-master:   libglib2.0-data libgssapi-krb5-2 libgstreamer1.0-0 libk5crypto3 libkrb5-3
    k8s-master:   libkrb5support0 libldap-2.5-0 libldap-common libmm-glib0
    k8s-master:   libmodule-scandeps-perl libpackagekit-glib2-18 libpcap0.8 libpython3-stdlib
    k8s-master:   libpython3.10 libpython3.10-minimal libpython3.10-stdlib libss2 libssl3
    k8s-master:   linux-firmware linux-image-generic logsave modemmanager nano needrestart
    k8s-master:   openssl packagekit packagekit-tools python-apt-common python3 python3-apport
    k8s-master:   python3-apt python3-configobj python3-minimal python3-pkg-resources
    k8s-master:   python3-problem-report python3-setuptools python3-twisted python3-urllib3
    k8s-master:   python3.10 python3.10-minimal snapd sosreport ubuntu-advantage-tools
    k8s-master:   ubuntu-minimal ubuntu-pro-client ubuntu-pro-client-l10n vim vim-common
    k8s-master:   vim-runtime vim-tiny xxd
    k8s-master: 77 upgraded, 4 newly installed, 0 to remove and 0 not upgraded.
    k8s-master: Need to get 483 MB of archives.
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
    k8s-master: Get:44 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 bind9-host amd64 1:9.18.30-0ubuntu0.22.04.1 [52.1 kB]
    k8s-master: Get:45 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 bind9-dnsutils amd64 1:9.18.30-0ubuntu0.22.04.1 [158 kB]
    k8s-master: Get:46 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 bind9-libs amd64 1:9.18.30-0ubuntu0.22.04.1 [1,257 kB]
    k8s-master: Get:47 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 busybox-static amd64 1:1.30.1-7ubuntu3.1 [1,019 kB]
    k8s-master: Get:48 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 dmidecode amd64 3.3-3ubuntu0.2 [68.5 kB]
    k8s-master: Get:49 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpcap0.8 amd64 1.10.1-4ubuntu1.22.04.1 [145 kB]
    k8s-master: Get:50 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 nano amd64 6.2-1ubuntu0.1 [280 kB]
    k8s-master: Get:51 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-problem-report all 2.20.11-0ubuntu82.6 [11.1 kB]
    k8s-master: Get:52 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-apport all 2.20.11-0ubuntu82.6 [89.0 kB]
    k8s-master: Get:53 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 apport all 2.20.11-0ubuntu82.6 [134 kB]
    k8s-master: Get:54 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 busybox-initramfs amd64 1:1.30.1-7ubuntu3.1 [177 kB]
    k8s-master: Get:55 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpackagekit-glib2-18 amd64 1.2.5-2ubuntu3 [124 kB]
    k8s-master: Get:56 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 gir1.2-packagekitglib-1.0 amd64 1.2.5-2ubuntu3 [25.3 kB]
    k8s-master: Get:57 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libarchive13 amd64 3.6.0-1ubuntu1.3 [369 kB]
    k8s-master: Get:58 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libldap-2.5-0 amd64 2.5.18+dfsg-0ubuntu0.22.04.2 [183 kB]
    k8s-master: Get:59 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libcurl3-gnutls amd64 7.81.0-1ubuntu1.20 [284 kB]
    k8s-master: Get:60 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libgstreamer1.0-0 amd64 1.20.3-0ubuntu1.1 [984 kB]
    k8s-master: Get:61 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libldap-common all 2.5.18+dfsg-0ubuntu0.22.04.2 [15.9 kB]
    k8s-master: Get:62 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libmm-glib0 amd64 1.20.0-1~ubuntu22.04.4 [262 kB]
    k8s-master: Get:63 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libmodule-scandeps-perl all 1.31-1ubuntu0.1 [30.7 kB]
    k8s-master: Get:64 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-firmware all 20220329.git681281e4-0ubuntu3.36 [312 MB]
    k8s-master: Get:65 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-modules-5.15.0-130-generic amd64 5.15.0-130.140 [22.7 MB]
    k8s-master: Get:66 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-image-5.15.0-130-generic amd64 5.15.0-130.140 [11.6 MB]
    k8s-master: Get:67 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-modules-extra-5.15.0-130-generic amd64 5.15.0-130.140 [63.9 MB]
    k8s-master: Get:68 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 amd64-microcode amd64 3.20191218.1ubuntu2.3 [67.9 kB]
    k8s-master: Get:69 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 intel-microcode amd64 3.20241112.0ubuntu0.22.04.1 [7,045 kB]
    k8s-master: Get:70 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-image-generic amd64 5.15.0.130.128 [2,524 B]
    k8s-master: Get:71 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 modemmanager amd64 1.20.0-1~ubuntu22.04.4 [1,094 kB]
    k8s-master: Get:72 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 needrestart all 3.5-5ubuntu2.4 [45.2 kB]
    k8s-master: Get:73 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 packagekit-tools amd64 1.2.5-2ubuntu3 [28.8 kB]
    k8s-master: Get:74 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 packagekit amd64 1.2.5-2ubuntu3 [442 kB]
    k8s-master: Get:75 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-configobj all 5.0.6-5ubuntu0.1 [34.9 kB]
    k8s-master: Get:76 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 python3-packaging all 21.3-1 [30.7 kB]
    k8s-master: Get:77 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-twisted all 22.1.0-2ubuntu2.6 [2,007 kB]
    k8s-master: Get:78 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-urllib3 all 1.26.5-1~exp1ubuntu0.2 [98.3 kB]
    k8s-master: Get:79 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 snapd amd64 2.66.1+22.04 [27.6 MB]
    k8s-master: Get:80 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 sosreport amd64 4.7.2-0ubuntu1~22.04.2 [352 kB]
    k8s-master: Get:81 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 cloud-init all 24.4-0ubuntu1~22.04.1 [565 kB]
    k8s-master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-master: Fetched 483 MB in 19s (25.8 MB/s)
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
    k8s-master: Preparing to unpack .../21-bind9-host_1%3a9.18.30-0ubuntu0.22.04.1_amd64.deb ...
    k8s-master: Unpacking bind9-host (1:9.18.30-0ubuntu0.22.04.1) over (1:9.18.28-0ubuntu0.22.04.1) ...
    k8s-master: Preparing to unpack .../22-bind9-dnsutils_1%3a9.18.30-0ubuntu0.22.04.1_amd64.deb ...
    k8s-master: Unpacking bind9-dnsutils (1:9.18.30-0ubuntu0.22.04.1) over (1:9.18.28-0ubuntu0.22.04.1) ...
    k8s-master: Preparing to unpack .../23-bind9-libs_1%3a9.18.30-0ubuntu0.22.04.1_amd64.deb ...
    k8s-master: Unpacking bind9-libs:amd64 (1:9.18.30-0ubuntu0.22.04.1) over (1:9.18.28-0ubuntu0.22.04.1) ...
    k8s-master: Preparing to unpack .../24-busybox-static_1%3a1.30.1-7ubuntu3.1_amd64.deb ...
    k8s-master: Unpacking busybox-static (1:1.30.1-7ubuntu3.1) over (1:1.30.1-7ubuntu3) ...
    k8s-master: Preparing to unpack .../25-dmidecode_3.3-3ubuntu0.2_amd64.deb ...
    k8s-master: Unpacking dmidecode (3.3-3ubuntu0.2) over (3.3-3ubuntu0.1) ...
    k8s-master: Preparing to unpack .../26-libpcap0.8_1.10.1-4ubuntu1.22.04.1_amd64.deb ...
    k8s-master: Unpacking libpcap0.8:amd64 (1.10.1-4ubuntu1.22.04.1) over (1.10.1-4build1) ...
    k8s-master: Preparing to unpack .../27-nano_6.2-1ubuntu0.1_amd64.deb ...
    k8s-master: Unpacking nano (6.2-1ubuntu0.1) over (6.2-1) ...
    k8s-master: Preparing to unpack .../28-python3-problem-report_2.20.11-0ubuntu82.6_all.deb ...
    k8s-master: Unpacking python3-problem-report (2.20.11-0ubuntu82.6) over (2.20.11-0ubuntu82.5) ...
    k8s-master: Preparing to unpack .../29-python3-apport_2.20.11-0ubuntu82.6_all.deb ...
    k8s-master: Unpacking python3-apport (2.20.11-0ubuntu82.6) over (2.20.11-0ubuntu82.5) ...
    k8s-master: Preparing to unpack .../30-apport_2.20.11-0ubuntu82.6_all.deb ...
    k8s-master: Unpacking apport (2.20.11-0ubuntu82.6) over (2.20.11-0ubuntu82.5) ...
    k8s-master: Preparing to unpack .../31-busybox-initramfs_1%3a1.30.1-7ubuntu3.1_amd64.deb ...
    k8s-master: Unpacking busybox-initramfs (1:1.30.1-7ubuntu3.1) over (1:1.30.1-7ubuntu3) ...
    k8s-master: Preparing to unpack .../32-libpackagekit-glib2-18_1.2.5-2ubuntu3_amd64.deb ...
    k8s-master: Unpacking libpackagekit-glib2-18:amd64 (1.2.5-2ubuntu3) over (1.2.5-2ubuntu2) ...
    k8s-master: Preparing to unpack .../33-gir1.2-packagekitglib-1.0_1.2.5-2ubuntu3_amd64.deb ...
    k8s-master: Unpacking gir1.2-packagekitglib-1.0 (1.2.5-2ubuntu3) over (1.2.5-2ubuntu2) ...
    k8s-master: Preparing to unpack .../34-libarchive13_3.6.0-1ubuntu1.3_amd64.deb ...
    k8s-master: Unpacking libarchive13:amd64 (3.6.0-1ubuntu1.3) over (3.6.0-1ubuntu1.1) ...
    k8s-master: Preparing to unpack .../35-libldap-2.5-0_2.5.18+dfsg-0ubuntu0.22.04.2_amd64.deb ...
    k8s-master: Unpacking libldap-2.5-0:amd64 (2.5.18+dfsg-0ubuntu0.22.04.2) over (2.5.18+dfsg-0ubuntu0.22.04.1) ...
    k8s-master: Preparing to unpack .../36-libcurl3-gnutls_7.81.0-1ubuntu1.20_amd64.deb ...
    k8s-master: Unpacking libcurl3-gnutls:amd64 (7.81.0-1ubuntu1.20) over (7.81.0-1ubuntu1.16) ...
    k8s-master: Preparing to unpack .../37-libgstreamer1.0-0_1.20.3-0ubuntu1.1_amd64.deb ...
    k8s-master: Unpacking libgstreamer1.0-0:amd64 (1.20.3-0ubuntu1.1) over (1.20.3-0ubuntu1) ...
    k8s-master: Preparing to unpack .../38-libldap-common_2.5.18+dfsg-0ubuntu0.22.04.2_all.deb ...
    k8s-master: Unpacking libldap-common (2.5.18+dfsg-0ubuntu0.22.04.2) over (2.5.18+dfsg-0ubuntu0.22.04.1) ...
    k8s-master: Preparing to unpack .../39-libmm-glib0_1.20.0-1~ubuntu22.04.4_amd64.deb ...
    k8s-master: Unpacking libmm-glib0:amd64 (1.20.0-1~ubuntu22.04.4) over (1.20.0-1~ubuntu22.04.3) ...
    k8s-master: Preparing to unpack .../40-libmodule-scandeps-perl_1.31-1ubuntu0.1_all.deb ...
    k8s-master: Unpacking libmodule-scandeps-perl (1.31-1ubuntu0.1) over (1.31-1) ...
    k8s-master: Preparing to unpack .../41-linux-firmware_20220329.git681281e4-0ubuntu3.36_all.deb ...
    k8s-master: Unpacking linux-firmware (20220329.git681281e4-0ubuntu3.36) over (20220329.git681281e4-0ubuntu3.31) ...
    k8s-master: Selecting previously unselected package linux-modules-5.15.0-130-generic.
    k8s-master: Preparing to unpack .../42-linux-modules-5.15.0-130-generic_5.15.0-130.140_amd64.deb ...
    k8s-master: Unpacking linux-modules-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: Selecting previously unselected package linux-image-5.15.0-130-generic.
    k8s-master: Preparing to unpack .../43-linux-image-5.15.0-130-generic_5.15.0-130.140_amd64.deb ...
    k8s-master: Unpacking linux-image-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: Selecting previously unselected package linux-modules-extra-5.15.0-130-generic.
    k8s-master: Preparing to unpack .../44-linux-modules-extra-5.15.0-130-generic_5.15.0-130.140_amd64.deb ...
    k8s-master: Unpacking linux-modules-extra-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-master: Preparing to unpack .../45-amd64-microcode_3.20191218.1ubuntu2.3_amd64.deb ...
    k8s-master: Unpacking amd64-microcode (3.20191218.1ubuntu2.3) over (3.20191218.1ubuntu2.2) ...
    k8s-master: Preparing to unpack .../46-intel-microcode_3.20241112.0ubuntu0.22.04.1_amd64.deb ...
    k8s-master: Unpacking intel-microcode (3.20241112.0ubuntu0.22.04.1) over (3.20240514.0ubuntu0.22.04.1) ...
    k8s-master: Preparing to unpack .../47-linux-image-generic_5.15.0.130.128_amd64.deb ...
    k8s-master: Unpacking linux-image-generic (5.15.0.130.128) over (5.15.0.116.116) ...
    k8s-master: Preparing to unpack .../48-modemmanager_1.20.0-1~ubuntu22.04.4_amd64.deb ...
    k8s-master: Unpacking modemmanager (1.20.0-1~ubuntu22.04.4) over (1.20.0-1~ubuntu22.04.3) ...
    k8s-master: Preparing to unpack .../49-needrestart_3.5-5ubuntu2.4_all.deb ...
    k8s-master: Unpacking needrestart (3.5-5ubuntu2.4) over (3.5-5ubuntu2.1) ...
    k8s-master: Preparing to unpack .../50-packagekit-tools_1.2.5-2ubuntu3_amd64.deb ...
    k8s-master: Unpacking packagekit-tools (1.2.5-2ubuntu3) over (1.2.5-2ubuntu2) ...
    k8s-master: Preparing to unpack .../51-packagekit_1.2.5-2ubuntu3_amd64.deb ...
    k8s-master: Unpacking packagekit (1.2.5-2ubuntu3) over (1.2.5-2ubuntu2) ...
    k8s-master: Preparing to unpack .../52-python3-configobj_5.0.6-5ubuntu0.1_all.deb ...
    k8s-master: Unpacking python3-configobj (5.0.6-5ubuntu0.1) over (5.0.6-5) ...
    k8s-master: Selecting previously unselected package python3-packaging.
    k8s-master: Preparing to unpack .../53-python3-packaging_21.3-1_all.deb ...
    k8s-master: Unpacking python3-packaging (21.3-1) ...
    k8s-master: Preparing to unpack .../54-python3-twisted_22.1.0-2ubuntu2.6_all.deb ...
    k8s-master: Unpacking python3-twisted (22.1.0-2ubuntu2.6) over (22.1.0-2ubuntu2.4) ...
    k8s-master: Preparing to unpack .../55-python3-urllib3_1.26.5-1~exp1ubuntu0.2_all.deb ...
    k8s-master: Unpacking python3-urllib3 (1.26.5-1~exp1ubuntu0.2) over (1.26.5-1~exp1ubuntu0.1) ...
    k8s-master: Preparing to unpack .../56-snapd_2.66.1+22.04_amd64.deb ...
    k8s-master: Unpacking snapd (2.66.1+22.04) over (2.63+22.04) ...
    k8s-master: Preparing to unpack .../57-sosreport_4.7.2-0ubuntu1~22.04.2_amd64.deb ...
    k8s-master: Unpacking sosreport (4.7.2-0ubuntu1~22.04.2) over (4.5.6-0ubuntu1~22.04.2) ...
    k8s-master: Preparing to unpack .../58-cloud-init_24.4-0ubuntu1~22.04.1_all.deb ...
    k8s-master: Unpacking cloud-init (24.4-0ubuntu1~22.04.1) over (24.1.3-0ubuntu1~22.04.5) ...
    k8s-master: dpkg: warning: unable to delete old directory '/etc/systemd/system/sshd-keygen@.service.d': Directory not empty
    k8s-master: Setting up libexpat1:amd64 (2.4.7-1ubuntu0.5) ...
    k8s-master: Setting up libapparmor1:amd64 (3.0.4-2ubuntu2.4) ...
    k8s-master: Setting up apt-utils (2.4.13) ...
    k8s-master: Setting up bind9-libs:amd64 (1:9.18.30-0ubuntu0.22.04.1) ...
    k8s-master: Setting up linux-firmware (20220329.git681281e4-0ubuntu3.36) ...
    k8s-master: update-initramfs: Generating /boot/initrd.img-5.15.0-116-generic
    k8s-master: find: ‘/var/tmp/mkinitramfs_tb5mrf/lib/firmware’: No such file or directory
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
    k8s-master: Setting up bind9-host (1:9.18.30-0ubuntu0.22.04.1) ...
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
    k8s-master: Setting up bind9-dnsutils (1:9.18.30-0ubuntu0.22.04.1) ...
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
    k8s-master: find: ‘/var/tmp/mkinitramfs_Aom8vf/lib/firmware’: No such file or directory
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
    k8s-master: find: ‘/var/tmp/mkinitramfs_aJNUpS/lib/firmware’: No such file or directory
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
    k8s-master: find: ‘/var/tmp/mkinitramfs_5jBDLq/lib/firmware’: No such file or directory
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
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-vvvbu7.sh
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
    k8s-master: 0 upgraded, 2 newly installed, 0 to remove and 0 not upgraded.
    k8s-master: Need to get 46.2 MB of archives.
    k8s-master: After this operation, 175 MB of additional disk space will be used.
    k8s-master: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 runc amd64 1.1.12-0ubuntu2~22.04.1 [8,405 kB]
    k8s-master: Get:2 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 containerd amd64 1.7.12-0ubuntu2~22.04.1 [37.8 MB]
    k8s-master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-master: Fetched 46.2 MB in 5s (9,073 kB/s)
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
    k8s-master:      Active: active (running) since Wed 2025-01-08 08:49:08 UTC; 18ms ago
    k8s-master:        Docs: https://containerd.io
    k8s-master:     Process: 49772 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
    k8s-master:    Main PID: 49773 (containerd)
    k8s-master:       Tasks: 8
    k8s-master:      Memory: 13.7M
    k8s-master:         CPU: 97ms
    k8s-master:      CGroup: /system.slice/containerd.service
    k8s-master:              └─49773 /usr/bin/containerd
    k8s-master:
    k8s-master: Jan 08 08:49:08 k8s-master containerd[49773]: time="2025-01-08T08:49:08.518099328Z" level=info msg=serving... address=/run/containerd/containerd.sock.ttrpc
    k8s-master: Jan 08 08:49:08 k8s-master containerd[49773]: time="2025-01-08T08:49:08.518250807Z" level=info msg=serving... address=/run/containerd/containerd.sock    
    k8s-master: Jan 08 08:49:08 k8s-master containerd[49773]: time="2025-01-08T08:49:08.520287620Z" level=info msg="Start subscribing containerd event"
    k8s-master: Jan 08 08:49:08 k8s-master containerd[49773]: time="2025-01-08T08:49:08.520999078Z" level=info msg="Start recovering state"
    k8s-master: Jan 08 08:49:08 k8s-master containerd[49773]: time="2025-01-08T08:49:08.521197363Z" level=info msg="Start event monitor"
    k8s-master: Jan 08 08:49:08 k8s-master containerd[49773]: time="2025-01-08T08:49:08.521278685Z" level=info msg="Start snapshots syncer"
    k8s-master: Jan 08 08:49:08 k8s-master containerd[49773]: time="2025-01-08T08:49:08.521335548Z" level=info msg="Start cni network conf syncer for default"
    k8s-master: Jan 08 08:49:08 k8s-master containerd[49773]: time="2025-01-08T08:49:08.521402297Z" level=info msg="Start streaming server"
    k8s-master: Jan 08 08:49:08 k8s-master systemd[1]: Started containerd container runtime.
    k8s-master: Jan 08 08:49:08 k8s-master containerd[49773]: time="2025-01-08T08:49:08.533379500Z" level=info msg="containerd successfully booted in 0.051769s"
==> k8s-master: Running provisioner: shell...
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-khbdkx.sh
    k8s-master: Hit:1 http://us.archive.ubuntu.com/ubuntu jammy InRelease
    k8s-master: Hit:2 http://security.ubuntu.com/ubuntu jammy-security InRelease
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
    k8s-master: 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
    k8s-master: Directory exists
    k8s-master: deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /
    k8s-master: Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  InRelease [1,186 B]
    k8s-master: Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  Packages [2,731 B]
    k8s-master: Hit:3 http://security.ubuntu.com/ubuntu jammy-security InRelease
    k8s-master: Hit:4 http://us.archive.ubuntu.com/ubuntu jammy InRelease
    k8s-master: Hit:5 http://us.archive.ubuntu.com/ubuntu jammy-updates InRelease
    k8s-master: Hit:6 http://us.archive.ubuntu.com/ubuntu jammy-backports InRelease
    k8s-master: Fetched 3,917 B in 1s (3,784 B/s)
    k8s-master: Reading package lists...
    k8s-master: Reading package lists...
    k8s-master: Building dependency tree...
    k8s-master: Reading state information...
    k8s-master: The following additional packages will be installed:
    k8s-master:   conntrack cri-tools kubernetes-cni
    k8s-master: The following NEW packages will be installed:
    k8s-master:   conntrack cri-tools kubeadm kubectl kubelet kubernetes-cni
    k8s-master: 0 upgraded, 6 newly installed, 0 to remove and 0 not upgraded.
    k8s-master: Need to get 92.7 MB of archives.
    k8s-master: After this operation, 338 MB of additional disk space will be used.
    k8s-master: Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  cri-tools 1.32.0-1.1 [16.3 MB]
    k8s-master: Get:3 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 conntrack amd64 1:1.4.6-2build2 [33.5 kB]
    k8s-master: Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  kubeadm 1.32.0-1.1 [12.2 MB]
    k8s-master: Get:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  kubectl 1.32.0-1.1 [11.3 MB]
    k8s-master: Get:5 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  kubernetes-cni 1.6.0-1.1 [37.8 MB]
    k8s-master: Get:6 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  kubelet 1.32.0-1.1 [15.2 MB]
    k8s-master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-master: Fetched 92.7 MB in 3s (36.3 MB/s)
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
    k8s-master: 0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
    k8s-master: Need to get 6,806 kB of archives.
    k8s-master: After this operation, 46.2 MB of additional disk space will be used.
    k8s-master: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/universe amd64 containernetworking-plugins amd64 0.9.1+ds1-1ubuntu0.1 [6,806 kB]
    k8s-master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-master: Fetched 6,806 kB in 3s (2,285 kB/s)
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
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-p5hou0.sh
    k8s-master: Reading package lists...
    k8s-master: Building dependency tree...
    k8s-master: Reading state information...
    k8s-master: 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
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
    k8s-master: 0 upgraded, 1 newly installed, 3 to remove and 0 not upgraded.
    k8s-master: Need to get 11.8 MB of archives.
    k8s-master: After this operation, 352 MB disk space will be freed.
    k8s-master: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-image-unsigned-5.15.0-130-generic amd64 5.15.0-130.140 [11.8 MB]
    k8s-master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-master: Fetched 11.8 MB in 3s (3,887 kB/s)
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
    k8s-master: Vacuuming done, freed 0B of archived journals from /var/log/journal/2935803275f04062998ae00c735b5e2f.
    k8s-master: Vacuuming done, freed 0B of archived journals from /run/log/journal.
    k8s-master: Vacuuming done, freed 0B of archived journals from /var/log/journal.
==> k8s-master: Running provisioner: shell...
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-n0whks.sh
    k8s-master: [init] Using Kubernetes version: v1.32.0
    k8s-master: [preflight] Running pre-flight checks
    k8s-master: [preflight] Pulling images required for setting up a Kubernetes cluster
    k8s-master: [preflight] This might take a minute or two, depending on the speed of your internet connection
    k8s-master: [preflight] You can also perform this action beforehand using 'kubeadm config images pull'
    k8s-master: W0108 08:49:53.583384   51655 checks.go:846] detected that the sandbox image "registry.k8s.io/pause:3.8" of the container runtime is inconsistent with that used by kubeadm.It is recommended to use "registry.k8s.io/pause:3.10" as the CRI sandbox image.
    k8s-master: [certs] Using certificateDir folder "/etc/kubernetes/pki"
    k8s-master: [certs] Generating "ca" certificate and key
    k8s-master: [certs] Generating "apiserver" certificate and key
    k8s-master: [certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.128.0.101]
    k8s-master: [certs] Generating "apiserver-kubelet-client" certificate and key
    k8s-master: [certs] Generating "front-proxy-ca" certificate and key
    k8s-master: [certs] Generating "front-proxy-client" certificate and key
    k8s-master: [certs] Generating "etcd/ca" certificate and key
    k8s-master: [certs] Generating "etcd/server" certificate and key
    k8s-master: [certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [192.128.0.101 127.0.0.1 ::1]
    k8s-master: [certs] Generating "etcd/peer" certificate and key
    k8s-master: [certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [192.128.0.101 127.0.0.1 ::1]
    k8s-master: [certs] Generating "etcd/healthcheck-client" certificate and key
    k8s-master: [certs] Generating "apiserver-etcd-client" certificate and key
    k8s-master: [certs] Generating "sa" key and public key
    k8s-master: [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
    k8s-master: [kubeconfig] Writing "admin.conf" kubeconfig file
    k8s-master: [kubeconfig] Writing "super-admin.conf" kubeconfig file
    k8s-master: [kubeconfig] Writing "kubelet.conf" kubeconfig file
    k8s-master: [kubeconfig] Writing "controller-manager.conf" kubeconfig file
    k8s-master: [kubeconfig] Writing "scheduler.conf" kubeconfig file
    k8s-master: [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
    k8s-master: [control-plane] Using manifest folder "/etc/kubernetes/manifests"
    k8s-master: [control-plane] Creating static Pod manifest for "kube-apiserver"
    k8s-master: [control-plane] Creating static Pod manifest for "kube-controller-manager"
    k8s-master: [control-plane] Creating static Pod manifest for "kube-scheduler"
    k8s-master: [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    k8s-master: [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    k8s-master: [kubelet-start] Starting the kubelet
    k8s-master: [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests"
    k8s-master: [kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
    k8s-master: [kubelet-check] The kubelet is healthy after 1.004344624s
    k8s-master: [api-check] Waiting for a healthy API server. This can take up to 4m0s
    k8s-master: [api-check] The API server is healthy after 12.005198928s
    k8s-master: [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
    k8s-master: [kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
    k8s-master: [upload-certs] Skipping phase. Please see --upload-certs
    k8s-master: [mark-control-plane] Marking the node k8s-master as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
    k8s-master: [mark-control-plane] Marking the node k8s-master as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
    k8s-master: [bootstrap-token] Using token: ryurlx.xpxo9dxwu5e8ksli
    k8s-master: [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
    k8s-master: [bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
    k8s-master: [bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
    k8s-master: [bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
    k8s-master: [bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
    k8s-master: [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
    k8s-master: [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
    k8s-master: [addons] Applied essential addon: CoreDNS
    k8s-master: [addons] Applied essential addon: kube-proxy
    k8s-master:
    k8s-master: Your Kubernetes control-plane has initialized successfully!
    k8s-master:
    k8s-master: To start using your cluster, you need to run the following as a regular user:
    k8s-master:
    k8s-master:   mkdir -p $HOME/.kube
    k8s-master:   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    k8s-master:   sudo chown $(id -u):$(id -g) $HOME/.kube/config
    k8s-master:
    k8s-master: Alternatively, if you are the root user, you can run:
    k8s-master:
    k8s-master:   export KUBECONFIG=/etc/kubernetes/admin.conf
    k8s-master: 
    k8s-master: You should now deploy a pod network to the cluster.
    k8s-master: Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    k8s-master:   https://kubernetes.io/docs/concepts/cluster-administration/addons/
    k8s-master:
    k8s-master: Then you can join any number of worker nodes by running the following on each as root:
    k8s-master:
    k8s-master: kubeadm join 192.128.0.101:6443 --token ryurlx.xpxo9dxwu5e8ksli \
    k8s-master:         --discovery-token-ca-cert-hash sha256:eb73804389fd72b8d6819622865f46de6118ff793dd2b680e604b7881948636f
    k8s-master: join.sh
    k8s-master: kubeadm join 192.128.0.101:6443 --token harksc.umpfdsqymfzoc6lo --discovery-token-ca-cert-hash sha256:eb73804389fd72b8d6819622865f46de6118ff793dd2b680e604b7881948636f
==> k8s-master: Running provisioner: shell...
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-e71lb7.sh
==> k8s-master: Running provisioner: shell...
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-s40n9w.sh
    k8s-master: cp: overwrite '/root/.kube/config'? 
==> k8s-master: Running provisioner: shell...
    k8s-master: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-oaso9j.sh
    k8s-master: namespace/tigera-operator serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/bgpfilters.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/caliconodestatuses.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/ipreservations.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/kubecontrollersconfigurations.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/tiers.crd.projectcalico.org serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/adminnetworkpolicies.policy.networking.k8s.io serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/apiservers.operator.tigera.io serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/imagesets.operator.tigera.io serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/installations.operator.tigera.io serverside-applied
    k8s-master: customresourcedefinition.apiextensions.k8s.io/tigerastatuses.operator.tigera.io serverside-applied
    k8s-master: serviceaccount/tigera-operator serverside-applied
    k8s-master: clusterrole.rbac.authorization.k8s.io/tigera-operator serverside-applied
    k8s-master: clusterrolebinding.rbac.authorization.k8s.io/tigera-operator serverside-applied
    k8s-master: deployment.apps/tigera-operator serverside-applied
    k8s-master:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
    k8s-master:                                  Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
    k8s-master: total 0
    k8s-master: -rwxr-xr-x 1 root root 0 Jan  8 08:51 calicoctl
==> k8s-worker-1: Importing base box 'bento/ubuntu-22.04'...
==> k8s-worker-1: Matching MAC address for NAT networking...
==> k8s-worker-1: Checking if box 'bento/ubuntu-22.04' version '202407.23.0' is up to date...
==> k8s-worker-1: Setting the name of the VM: kubernetes-cluster_k8s-worker-1_1736326284378_95467
==> k8s-worker-1: Fixed port collision for 22 => 2222. Now on port 2200.
==> k8s-worker-1: Clearing any previously set network interfaces...
==> k8s-worker-1: Preparing network interfaces based on configuration...
    k8s-worker-1: Adapter 1: nat
    k8s-worker-1: Adapter 2: intnet
==> k8s-worker-1: Forwarding ports...
    k8s-worker-1: 22 (guest) => 2200 (host) (adapter 1)
==> k8s-worker-1: Running 'pre-boot' VM customizations...
==> k8s-worker-1: Booting VM...
==> k8s-worker-1: Waiting for machine to boot. This may take a few minutes...
    k8s-worker-1: SSH address: 127.0.0.1:2200
    k8s-worker-1: SSH username: vagrant
    k8s-worker-1: SSH auth method: private key
    k8s-worker-1: Warning: Connection reset. Retrying...
    k8s-worker-1: Warning: Connection aborted. Retrying...
    k8s-worker-1: 
    k8s-worker-1: Vagrant insecure key detected. Vagrant will automatically replace
    k8s-worker-1: this with a newly generated keypair for better security.
    k8s-worker-1: 
    k8s-worker-1: Inserting generated public key within guest...
==> k8s-worker-1: Machine booted and ready!
[k8s-worker-1] GuestAdditions seems to be installed (7.0.18) correctly, but not running.
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
==> k8s-worker-1: Attempting graceful shutdown of VM...
==> k8s-worker-1: Booting VM...
==> k8s-worker-1: Waiting for machine to boot. This may take a few minutes...
==> k8s-worker-1: Machine booted and ready!
==> k8s-worker-1: Checking for guest additions in VM...
    k8s-worker-1: The guest additions on this VM do not match the installed version of
    k8s-worker-1: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-worker-1: prevent things such as shared folders from working properly. If you see
    k8s-worker-1: shared folder errors, please make sure the guest additions within the
    k8s-worker-1: virtual machine match the version of VirtualBox you have installed on
    k8s-worker-1: your host and reload your VM.
    k8s-worker-1:
    k8s-worker-1: Guest Additions Version: 6.0.0 r127566
    k8s-worker-1: VirtualBox Version: 7.0
==> k8s-worker-1: Setting hostname...
==> k8s-worker-1: Configuring and enabling network interfaces...
==> k8s-worker-1: Mounting shared folders...
    k8s-worker-1: D:/workspace/kubernetes-cluster => /vagrant
==> k8s-worker-1: Running provisioner: shell...
    k8s-worker-1: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-82kbjh.sh
    k8s-worker-1: nc: connect to 127.0.0.1 port 6443 (tcp) failed: Connection refused
    k8s-worker-1: Hit:1 http://us.archive.ubuntu.com/ubuntu jammy InRelease
    k8s-worker-1: Get:2 http://security.ubuntu.com/ubuntu jammy-security InRelease [129 kB]
    k8s-worker-1: Get:3 http://us.archive.ubuntu.com/ubuntu jammy-updates InRelease [128 kB]
    k8s-worker-1: Get:4 http://us.archive.ubuntu.com/ubuntu jammy-backports InRelease [127 kB]
    k8s-worker-1: Get:5 http://security.ubuntu.com/ubuntu jammy-security/main amd64 Packages [2,036 kB]
    k8s-worker-1: Get:6 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages [2,271 kB]
    k8s-worker-1: Get:7 http://us.archive.ubuntu.com/ubuntu jammy-updates/main Translation-en [382 kB]
    k8s-worker-1: Get:8 http://us.archive.ubuntu.com/ubuntu jammy-updates/restricted amd64 Packages [2,867 kB]
    k8s-worker-1: Get:9 http://security.ubuntu.com/ubuntu jammy-security/main Translation-en [321 kB]
    k8s-worker-1: Get:10 http://us.archive.ubuntu.com/ubuntu jammy-updates/restricted Translation-en [500 kB]
    k8s-worker-1: Get:11 http://security.ubuntu.com/ubuntu jammy-security/restricted amd64 Packages [2,761 kB]
    k8s-worker-1: Get:12 http://us.archive.ubuntu.com/ubuntu jammy-updates/universe amd64 Packages [1,181 kB]
    k8s-worker-1: Get:13 http://us.archive.ubuntu.com/ubuntu jammy-updates/universe Translation-en [288 kB]
    k8s-worker-1: Get:14 http://us.archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 Packages [44.5 kB]
    k8s-worker-1: Get:15 http://us.archive.ubuntu.com/ubuntu jammy-updates/multiverse Translation-en [11.5 kB]
    k8s-worker-1: Get:16 http://us.archive.ubuntu.com/ubuntu jammy-backports/main amd64 Packages [67.7 kB]
    k8s-worker-1: Get:17 http://us.archive.ubuntu.com/ubuntu jammy-backports/main Translation-en [11.1 kB]
    k8s-worker-1: Get:18 http://us.archive.ubuntu.com/ubuntu jammy-backports/universe amd64 Packages [28.9 kB]
    k8s-worker-1: Get:19 http://us.archive.ubuntu.com/ubuntu jammy-backports/universe Translation-en [16.5 kB]
    k8s-worker-1: Get:20 http://security.ubuntu.com/ubuntu jammy-security/restricted Translation-en [482 kB]
    k8s-worker-1: Get:21 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 Packages [958 kB]
    k8s-worker-1: Get:22 http://security.ubuntu.com/ubuntu jammy-security/universe Translation-en [204 kB]
    k8s-worker-1: Get:23 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 Packages [37.6 kB]
    k8s-worker-1: Get:24 http://security.ubuntu.com/ubuntu jammy-security/multiverse Translation-en [8,260 B]
    k8s-worker-1: Fetched 14.9 MB in 7s (2,191 kB/s)
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Building dependency tree...
    k8s-worker-1: Reading state information...
    k8s-worker-1: The following additional packages will be installed:
    k8s-worker-1:   libcurl4
    k8s-worker-1: The following NEW packages will be installed:
    k8s-worker-1:   apt-transport-https
    k8s-worker-1: The following packages will be upgraded:
    k8s-worker-1:   ca-certificates curl libcurl4
    k8s-worker-1: 3 upgraded, 1 newly installed, 0 to remove and 77 not upgraded.
    k8s-worker-1: Need to get 647 kB of archives.
    k8s-worker-1: After this operation, 181 kB of additional disk space will be used.
    k8s-worker-1: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 ca-certificates all 20240203~22.04.1 [162 kB]
    k8s-worker-1: Get:2 http://us.archive.ubuntu.com/ubuntu jammy-updates/universe amd64 apt-transport-https all 2.4.13 [1,510 B]
    k8s-worker-1: Get:3 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 curl amd64 7.81.0-1ubuntu1.20 [194 kB]
    k8s-worker-1: Get:4 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libcurl4 amd64 7.81.0-1ubuntu1.20 [289 kB]
    k8s-worker-1: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-worker-1: Fetched 647 kB in 2s (311 kB/s)
(Reading database ... 44902 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../ca-certificates_20240203~22.04.1_all.deb ...
    k8s-worker-1: Unpacking ca-certificates (20240203~22.04.1) over (20230311ubuntu0.22.04.1) ...
    k8s-worker-1: Selecting previously unselected package apt-transport-https.
    k8s-worker-1: Preparing to unpack .../apt-transport-https_2.4.13_all.deb ...
    k8s-worker-1: Unpacking apt-transport-https (2.4.13) ...
    k8s-worker-1: Preparing to unpack .../curl_7.81.0-1ubuntu1.20_amd64.deb ...
    k8s-worker-1: Unpacking curl (7.81.0-1ubuntu1.20) over (7.81.0-1ubuntu1.16) ...
    k8s-worker-1: Preparing to unpack .../libcurl4_7.81.0-1ubuntu1.20_amd64.deb ...
    k8s-worker-1: Unpacking libcurl4:amd64 (7.81.0-1ubuntu1.20) over (7.81.0-1ubuntu1.16) ...
    k8s-worker-1: Setting up apt-transport-https (2.4.13) ...
    k8s-worker-1: Setting up ca-certificates (20240203~22.04.1) ...
    k8s-worker-1: Updating certificates in /etc/ssl/certs...
    k8s-worker-1: rehash: warning: skipping ca-certificates.crt,it does not contain exactly one certificate or CRL
    k8s-worker-1: 14 added, 5 removed; done.
    k8s-worker-1: Setting up libcurl4:amd64 (7.81.0-1ubuntu1.20) ...
    k8s-worker-1: Setting up curl (7.81.0-1ubuntu1.20) ...
    k8s-worker-1: Processing triggers for man-db (2.10.2-1) ...
    k8s-worker-1: Processing triggers for libc-bin (2.35-0ubuntu3.8) ...
    k8s-worker-1: Processing triggers for ca-certificates (20240203~22.04.1) ...
    k8s-worker-1: Updating certificates in /etc/ssl/certs...
    k8s-worker-1: 0 added, 0 removed; done.
    k8s-worker-1: Running hooks in /etc/ca-certificates/update.d...
    k8s-worker-1: done.
    k8s-worker-1: 
    k8s-worker-1: Running kernel seems to be up-to-date.
    k8s-worker-1:
    k8s-worker-1: No services need to be restarted.
    k8s-worker-1:
    k8s-worker-1: No containers need to be restarted.
    k8s-worker-1:
    k8s-worker-1: No user sessions are running outdated binaries.
    k8s-worker-1:
    k8s-worker-1: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Building dependency tree...
    k8s-worker-1: Reading state information...
    k8s-worker-1: iptables is already the newest version (1.8.7-1ubuntu5.2).
    k8s-worker-1: tmux is already the newest version (3.2a-4ubuntu0.2).
    k8s-worker-1: The following additional packages will be installed:
    k8s-worker-1:   keyutils libipset13 libjq1 libnfsidmap1 libonig5 rpcbind
    k8s-worker-1: Suggested packages:
    k8s-worker-1:   heartbeat keepalived ldirectord watchdog
    k8s-worker-1: The following NEW packages will be installed:
    k8s-worker-1:   arptables ebtables ipset ipvsadm jq keyutils libipset13 libjq1 libnfsidmap1
    k8s-worker-1:   libonig5 net-tools nfs-common rpcbind
    k8s-worker-1: 0 upgraded, 13 newly installed, 0 to remove and 77 not upgraded.
    k8s-worker-1: Need to get 1,203 kB of archives.
    k8s-worker-1: After this operation, 4,255 kB of additional disk space will be used.
    k8s-worker-1: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libnfsidmap1 amd64 1:2.6.1-1ubuntu1.2 [42.9 kB]
    k8s-worker-1: Get:2 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 rpcbind amd64 1.2.6-2build1 [46.6 kB]
    k8s-worker-1: Get:3 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 keyutils amd64 1.6.1-2ubuntu3 [50.4 kB]
    k8s-worker-1: Get:4 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 nfs-common amd64 1:2.6.1-1ubuntu1.2 [241 kB]
    k8s-worker-1: Get:5 http://us.archive.ubuntu.com/ubuntu jammy/universe amd64 arptables amd64 0.0.5-3 [38.1 kB]
    k8s-worker-1: Get:6 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 ebtables amd64 2.0.11-4build2 [84.9 kB]
    k8s-worker-1: Get:7 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 libonig5 amd64 6.9.7.1-2build1 [172 kB]
    k8s-worker-1: Get:8 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 libjq1 amd64 1.6-2.1ubuntu3 [133 kB]
    k8s-worker-1: Get:9 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 jq amd64 1.6-2.1ubuntu3 [52.5 kB]
    k8s-worker-1: Get:10 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 libipset13 amd64 7.15-1build1 [63.4 kB]
    k8s-worker-1: Get:11 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 net-tools amd64 1.60+git20181103.0eebece-1ubuntu5 [204 kB]
    k8s-worker-1: Get:12 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 ipset amd64 7.15-1build1 [32.8 kB]
    k8s-worker-1: Get:13 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 ipvsadm amd64 1:1.31-1build2 [42.2 kB]
    k8s-worker-1: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-worker-1: Fetched 1,203 kB in 2s (504 kB/s)
    k8s-worker-1: Selecting previously unselected package libnfsidmap1:amd64.
(Reading database ... 44915 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../00-libnfsidmap1_1%3a2.6.1-1ubuntu1.2_amd64.deb ...
    k8s-worker-1: Unpacking libnfsidmap1:amd64 (1:2.6.1-1ubuntu1.2) ...
    k8s-worker-1: Selecting previously unselected package rpcbind.
    k8s-worker-1: Preparing to unpack .../01-rpcbind_1.2.6-2build1_amd64.deb ...
    k8s-worker-1: Unpacking rpcbind (1.2.6-2build1) ...
    k8s-worker-1: Selecting previously unselected package keyutils.
    k8s-worker-1: Preparing to unpack .../02-keyutils_1.6.1-2ubuntu3_amd64.deb ...
    k8s-worker-1: Unpacking keyutils (1.6.1-2ubuntu3) ...
    k8s-worker-1: Selecting previously unselected package nfs-common.
    k8s-worker-1: Preparing to unpack .../03-nfs-common_1%3a2.6.1-1ubuntu1.2_amd64.deb ...
    k8s-worker-1: Unpacking nfs-common (1:2.6.1-1ubuntu1.2) ...
    k8s-worker-1: Selecting previously unselected package arptables.
    k8s-worker-1: Preparing to unpack .../04-arptables_0.0.5-3_amd64.deb ...
    k8s-worker-1: Unpacking arptables (0.0.5-3) ...
    k8s-worker-1: Selecting previously unselected package ebtables.
    k8s-worker-1: Preparing to unpack .../05-ebtables_2.0.11-4build2_amd64.deb ...
    k8s-worker-1: Unpacking ebtables (2.0.11-4build2) ...
    k8s-worker-1: Selecting previously unselected package libonig5:amd64.
    k8s-worker-1: Preparing to unpack .../06-libonig5_6.9.7.1-2build1_amd64.deb ...
    k8s-worker-1: Unpacking libonig5:amd64 (6.9.7.1-2build1) ...
    k8s-worker-1: Selecting previously unselected package libjq1:amd64.
    k8s-worker-1: Preparing to unpack .../07-libjq1_1.6-2.1ubuntu3_amd64.deb ...
    k8s-worker-1: Unpacking libjq1:amd64 (1.6-2.1ubuntu3) ...
    k8s-worker-1: Selecting previously unselected package jq.
    k8s-worker-1: Preparing to unpack .../08-jq_1.6-2.1ubuntu3_amd64.deb ...
    k8s-worker-1: Unpacking jq (1.6-2.1ubuntu3) ...
    k8s-worker-1: Selecting previously unselected package libipset13:amd64.
    k8s-worker-1: Preparing to unpack .../09-libipset13_7.15-1build1_amd64.deb ...
    k8s-worker-1: Unpacking libipset13:amd64 (7.15-1build1) ...
    k8s-worker-1: Selecting previously unselected package net-tools.
    k8s-worker-1: Preparing to unpack .../10-net-tools_1.60+git20181103.0eebece-1ubuntu5_amd64.deb ...
    k8s-worker-1: Unpacking net-tools (1.60+git20181103.0eebece-1ubuntu5) ...
    k8s-worker-1: Selecting previously unselected package ipset.
    k8s-worker-1: Preparing to unpack .../11-ipset_7.15-1build1_amd64.deb ...
    k8s-worker-1: Unpacking ipset (7.15-1build1) ...
    k8s-worker-1: Selecting previously unselected package ipvsadm.
    k8s-worker-1: Preparing to unpack .../12-ipvsadm_1%3a1.31-1build2_amd64.deb ...
    k8s-worker-1: Unpacking ipvsadm (1:1.31-1build2) ...
    k8s-worker-1: Setting up ipvsadm (1:1.31-1build2) ...
    k8s-worker-1: Setting up net-tools (1.60+git20181103.0eebece-1ubuntu5) ...
    k8s-worker-1: Setting up libnfsidmap1:amd64 (1:2.6.1-1ubuntu1.2) ...
    k8s-worker-1: Setting up rpcbind (1.2.6-2build1) ...
    k8s-worker-1: Created symlink /etc/systemd/system/multi-user.target.wants/rpcbind.service → /lib/systemd/system/rpcbind.service.
    k8s-worker-1: Created symlink /etc/systemd/system/sockets.target.wants/rpcbind.socket → /lib/systemd/system/rpcbind.socket.
    k8s-worker-1: Setting up ebtables (2.0.11-4build2) ...
    k8s-worker-1: Setting up arptables (0.0.5-3) ...
    k8s-worker-1: Setting up keyutils (1.6.1-2ubuntu3) ...
    k8s-worker-1: Setting up libipset13:amd64 (7.15-1build1) ...
    k8s-worker-1: Setting up ipset (7.15-1build1) ...
    k8s-worker-1: Setting up libonig5:amd64 (6.9.7.1-2build1) ...
    k8s-worker-1: Setting up libjq1:amd64 (1.6-2.1ubuntu3) ...
    k8s-worker-1: Setting up nfs-common (1:2.6.1-1ubuntu1.2) ...
    k8s-worker-1: 
    k8s-worker-1: Creating config file /etc/idmapd.conf with new version
    k8s-worker-1: 
    k8s-worker-1: Creating config file /etc/nfs.conf with new version
    k8s-worker-1: Adding system user `statd' (UID 115) ...
    k8s-worker-1: Adding new user `statd' (UID 115) with group `nogroup' ...
    k8s-worker-1: Not creating home directory `/var/lib/nfs'.
    k8s-worker-1: Created symlink /etc/systemd/system/multi-user.target.wants/nfs-client.target → /lib/systemd/system/nfs-client.target.
    k8s-worker-1: Created symlink /etc/systemd/system/remote-fs.target.wants/nfs-client.target → /lib/systemd/system/nfs-client.target.
    k8s-worker-1: auth-rpcgss-module.service is a disabled or a static unit, not starting it.
    k8s-worker-1: nfs-idmapd.service is a disabled or a static unit, not starting it.
    k8s-worker-1: nfs-utils.service is a disabled or a static unit, not starting it.
    k8s-worker-1: proc-fs-nfsd.mount is a disabled or a static unit, not starting it.
    k8s-worker-1: rpc-gssd.service is a disabled or a static unit, not starting it.
    k8s-worker-1: rpc-statd-notify.service is a disabled or a static unit, not starting it.
    k8s-worker-1: rpc-statd.service is a disabled or a static unit, not starting it.
    k8s-worker-1: rpc-svcgssd.service is a disabled or a static unit, not starting it.
    k8s-worker-1: rpc_pipefs.target is a disabled or a static unit, not starting it.
    k8s-worker-1: var-lib-nfs-rpc_pipefs.mount is a disabled or a static unit, not starting it.
    k8s-worker-1: Setting up jq (1.6-2.1ubuntu3) ...
    k8s-worker-1: Processing triggers for man-db (2.10.2-1) ...
    k8s-worker-1: Processing triggers for libc-bin (2.35-0ubuntu3.8) ...
    k8s-worker-1: 
    k8s-worker-1: Running kernel seems to be up-to-date.
    k8s-worker-1:
    k8s-worker-1: No services need to be restarted.
    k8s-worker-1:
    k8s-worker-1: No containers need to be restarted.
    k8s-worker-1:
    k8s-worker-1: No user sessions are running outdated binaries.
    k8s-worker-1: 
    k8s-worker-1: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    k8s-worker-1: grub-pc set on hold.
    k8s-worker-1: grub-pc-bin set on hold.
    k8s-worker-1: grub2-common set on hold.
    k8s-worker-1: grub-common set on hold.
    k8s-worker-1: overlay
    k8s-worker-1: br_netfilter
    k8s-worker-1: net.bridge.bridge-nf-call-iptables  = 1
    k8s-worker-1: net.bridge.bridge-nf-call-ip6tables = 1
    k8s-worker-1: net.ipv4.ip_forward                 = 1
    k8s-worker-1: net.ipv4.ip_forward = 1
    k8s-worker-1: * Applying /etc/sysctl.d/10-console-messages.conf ...
    k8s-worker-1: kernel.printk = 4 4 1 7
    k8s-worker-1: * Applying /etc/sysctl.d/10-ipv6-privacy.conf ...
    k8s-worker-1: net.ipv6.conf.all.use_tempaddr = 2
    k8s-worker-1: net.ipv6.conf.default.use_tempaddr = 2
    k8s-worker-1: * Applying /etc/sysctl.d/10-kernel-hardening.conf ...
    k8s-worker-1: kernel.kptr_restrict = 1
    k8s-worker-1: * Applying /etc/sysctl.d/10-magic-sysrq.conf ...
    k8s-worker-1: kernel.sysrq = 176
    k8s-worker-1: * Applying /etc/sysctl.d/10-network-security.conf ...
    k8s-worker-1: net.ipv4.conf.default.rp_filter = 2
    k8s-worker-1: net.ipv4.conf.all.rp_filter = 2
    k8s-worker-1: * Applying /etc/sysctl.d/10-ptrace.conf ...
    k8s-worker-1: kernel.yama.ptrace_scope = 1
    k8s-worker-1: * Applying /etc/sysctl.d/10-zeropage.conf ...
    k8s-worker-1: vm.mmap_min_addr = 65536
    k8s-worker-1: * Applying /usr/lib/sysctl.d/50-default.conf ...
    k8s-worker-1: kernel.core_uses_pid = 1
    k8s-worker-1: net.ipv4.conf.default.rp_filter = 2
    k8s-worker-1: net.ipv4.conf.default.accept_source_route = 0
    k8s-worker-1: sysctl: setting key "net.ipv4.conf.all.accept_source_route": Invalid argument
    k8s-worker-1: net.ipv4.conf.default.promote_secondaries = 1
    k8s-worker-1: sysctl: setting key "net.ipv4.conf.all.promote_secondaries": Invalid argument
    k8s-worker-1: net.ipv4.ping_group_range = 0 2147483647
    k8s-worker-1: net.core.default_qdisc = fq_codel
    k8s-worker-1: fs.protected_hardlinks = 1
    k8s-worker-1: fs.protected_symlinks = 1
    k8s-worker-1: fs.protected_regular = 1
    k8s-worker-1: fs.protected_fifos = 1
    k8s-worker-1: * Applying /usr/lib/sysctl.d/50-pid-max.conf ...
    k8s-worker-1: kernel.pid_max = 4194304
    k8s-worker-1: * Applying /usr/lib/sysctl.d/99-protect-links.conf ...
    k8s-worker-1: fs.protected_fifos = 1
    k8s-worker-1: fs.protected_hardlinks = 1
    k8s-worker-1: fs.protected_regular = 2
    k8s-worker-1: fs.protected_symlinks = 1
    k8s-worker-1: * Applying /etc/sysctl.d/99-sysctl.conf ...
    k8s-worker-1: * Applying /etc/sysctl.d/k8s.conf ...
    k8s-worker-1: net.ipv4.ip_forward = 1
    k8s-worker-1: * Applying /etc/sysctl.conf ...
    k8s-worker-1: net.ipv4.ip_forward = 1
    k8s-worker-1: Hit:1 http://us.archive.ubuntu.com/ubuntu jammy InRelease
    k8s-worker-1: Hit:2 http://security.ubuntu.com/ubuntu jammy-security InRelease
    k8s-worker-1: Hit:3 http://us.archive.ubuntu.com/ubuntu jammy-updates InRelease
    k8s-worker-1: Hit:4 http://us.archive.ubuntu.com/ubuntu jammy-backports InRelease
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Building dependency tree...
    k8s-worker-1: Reading state information...
    k8s-worker-1: Calculating upgrade...
    k8s-worker-1: The following NEW packages will be installed:
    k8s-worker-1:   linux-image-5.15.0-130-generic linux-modules-5.15.0-130-generic
    k8s-worker-1:   linux-modules-extra-5.15.0-130-generic python3-packaging
    k8s-worker-1: The following packages have been kept back:
    k8s-worker-1:   bind9-dnsutils bind9-host bind9-libs
    k8s-worker-1: The following packages will be upgraded:
    k8s-worker-1:   amd64-microcode apparmor apport apt apt-utils base-files busybox-initramfs
    k8s-worker-1:   busybox-static cloud-init distro-info-data dmidecode e2fsprogs
    k8s-worker-1:   gir1.2-packagekitglib-1.0 intel-microcode libapparmor1 libapt-pkg6.0
    k8s-worker-1:   libarchive13 libcom-err2 libcurl3-gnutls libexpat1 libext2fs2 libglib2.0-0
    k8s-worker-1:   libglib2.0-bin libglib2.0-data libgssapi-krb5-2 libgstreamer1.0-0
    k8s-worker-1:   libk5crypto3 libkrb5-3 libkrb5support0 libldap-2.5-0 libldap-common
    k8s-worker-1:   libmm-glib0 libmodule-scandeps-perl libpackagekit-glib2-18 libpcap0.8
    k8s-worker-1:   libpython3-stdlib libpython3.10 libpython3.10-minimal libpython3.10-stdlib
    k8s-worker-1:   libss2 libssl3 linux-firmware linux-image-generic logsave modemmanager nano
    k8s-worker-1:   needrestart openssl packagekit packagekit-tools python-apt-common python3
    k8s-worker-1:   python3-apport python3-apt python3-configobj python3-minimal
    k8s-worker-1:   python3-pkg-resources python3-problem-report python3-setuptools
    k8s-worker-1:   python3-twisted python3-urllib3 python3.10 python3.10-minimal snapd
    k8s-worker-1:   sosreport ubuntu-advantage-tools ubuntu-minimal ubuntu-pro-client
    k8s-worker-1:   ubuntu-pro-client-l10n vim vim-common vim-runtime vim-tiny xxd
    k8s-worker-1: 74 upgraded, 4 newly installed, 0 to remove and 3 not upgraded.
    k8s-worker-1: Need to get 481 MB of archives.
    k8s-worker-1: After this operation, 532 MB of additional disk space will be used.
    k8s-worker-1: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 base-files amd64 12ubuntu4.7 [61.9 kB]
    k8s-worker-1: Get:2 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libapt-pkg6.0 amd64 2.4.13 [912 kB]
    k8s-worker-1: Get:3 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 apt amd64 2.4.13 [1,363 kB]
    k8s-worker-1: Get:4 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 apt-utils amd64 2.4.13 [211 kB]
    k8s-worker-1: Get:5 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 logsave amd64 1.46.5-2ubuntu1.2 [10.1 kB]
    k8s-worker-1: Get:6 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libext2fs2 amd64 1.46.5-2ubuntu1.2 [208 kB]
    k8s-worker-1: Get:7 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 e2fsprogs amd64 1.46.5-2ubuntu1.2 [590 kB]
    k8s-worker-1: Get:8 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-minimal amd64 3.10.6-1~22.04.1 [24.3 kB]
    k8s-worker-1: Get:9 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3 amd64 3.10.6-1~22.04.1 [22.8 kB]
    k8s-worker-1: Get:10 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libexpat1 amd64 2.4.7-1ubuntu0.5 [91.5 kB]
    k8s-worker-1: Get:11 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpython3.10 amd64 3.10.12-1~22.04.7 [1,949 kB]
    k8s-worker-1: Get:12 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3.10 amd64 3.10.12-1~22.04.7 [509 kB]
    k8s-worker-1: Get:13 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpython3.10-stdlib amd64 3.10.12-1~22.04.7 [1,850 kB]
    k8s-worker-1: Get:14 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libssl3 amd64 3.0.2-0ubuntu1.18 [1,905 kB]
    k8s-worker-1: Get:15 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3.10-minimal amd64 3.10.12-1~22.04.7 [2,279 kB]
    k8s-worker-1: Get:16 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpython3.10-minimal amd64 3.10.12-1~22.04.7 [814 kB]
    k8s-worker-1: Get:17 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpython3-stdlib amd64 3.10.6-1~22.04.1 [6,812 B]
    k8s-worker-1: Get:18 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libcom-err2 amd64 1.46.5-2ubuntu1.2 [9,304 B]
    k8s-worker-1: Get:19 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libk5crypto3 amd64 1.19.2-2ubuntu0.4 [86.3 kB]
    k8s-worker-1: Get:20 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libkrb5support0 amd64 1.19.2-2ubuntu0.4 [32.3 kB]
    k8s-worker-1: Get:21 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libkrb5-3 amd64 1.19.2-2ubuntu0.4 [356 kB]
    k8s-worker-1: Get:22 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libgssapi-krb5-2 amd64 1.19.2-2ubuntu0.4 [144 kB]
    k8s-worker-1: Get:23 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libss2 amd64 1.46.5-2ubuntu1.2 [12.3 kB]
    k8s-worker-1: Get:24 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 distro-info-data all 0.52ubuntu0.8 [5,302 B]
    k8s-worker-1: Get:25 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libapparmor1 amd64 3.0.4-2ubuntu2.4 [39.7 kB]
    k8s-worker-1: Get:26 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libglib2.0-data all 2.72.4-0ubuntu2.4 [4,582 B]
    k8s-worker-1: Get:27 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libglib2.0-bin amd64 2.72.4-0ubuntu2.4 [80.9 kB]
    k8s-worker-1: Get:28 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libglib2.0-0 amd64 2.72.4-0ubuntu2.4 [1,465 kB]
    k8s-worker-1: Get:29 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 openssl amd64 3.0.2-0ubuntu1.18 [1,184 kB]
    k8s-worker-1: Get:30 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python-apt-common all 2.4.0ubuntu4 [14.6 kB]
    k8s-worker-1: Get:31 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-apt amd64 2.4.0ubuntu4 [164 kB]
    k8s-worker-1: Get:32 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-setuptools all 59.6.0-1.2ubuntu0.22.04.2 [340 kB]
    k8s-worker-1: Get:33 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-pkg-resources all 59.6.0-1.2ubuntu0.22.04.2 [133 kB]
    k8s-worker-1: Get:34 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 ubuntu-pro-client-l10n amd64 34~22.04 [19.1 kB]
    k8s-worker-1: Get:35 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 ubuntu-pro-client amd64 34~22.04 [221 kB]
    k8s-worker-1: Get:36 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 ubuntu-advantage-tools all 34~22.04 [10.9 kB]
    k8s-worker-1: Get:37 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 xxd amd64 2:8.2.3995-1ubuntu2.21 [52.3 kB]
    k8s-worker-1: Get:38 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 vim amd64 2:8.2.3995-1ubuntu2.21 [1,729 kB]
    k8s-worker-1: Get:39 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 vim-tiny amd64 2:8.2.3995-1ubuntu2.21 [708 kB]
    k8s-worker-1: Get:40 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 vim-runtime all 2:8.2.3995-1ubuntu2.21 [6,834 kB]
    k8s-worker-1: Get:41 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 vim-common all 2:8.2.3995-1ubuntu2.21 [81.5 kB]
    k8s-worker-1: Get:42 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 ubuntu-minimal amd64 1.481.4 [2,928 B]
    k8s-worker-1: Get:43 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 apparmor amd64 3.0.4-2ubuntu2.4 [598 kB]
    k8s-worker-1: Get:44 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 busybox-static amd64 1:1.30.1-7ubuntu3.1 [1,019 kB]
    k8s-worker-1: Get:45 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 dmidecode amd64 3.3-3ubuntu0.2 [68.5 kB]
    k8s-worker-1: Get:46 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpcap0.8 amd64 1.10.1-4ubuntu1.22.04.1 [145 kB]
    k8s-worker-1: Get:47 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 nano amd64 6.2-1ubuntu0.1 [280 kB]
    k8s-worker-1: Get:48 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-problem-report all 2.20.11-0ubuntu82.6 [11.1 kB]
    k8s-worker-1: Get:49 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-apport all 2.20.11-0ubuntu82.6 [89.0 kB]
    k8s-worker-1: Get:50 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 apport all 2.20.11-0ubuntu82.6 [134 kB]
    k8s-worker-1: Get:51 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 busybox-initramfs amd64 1:1.30.1-7ubuntu3.1 [177 kB]
    k8s-worker-1: Get:52 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libpackagekit-glib2-18 amd64 1.2.5-2ubuntu3 [124 kB]
    k8s-worker-1: Get:53 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 gir1.2-packagekitglib-1.0 amd64 1.2.5-2ubuntu3 [25.3 kB]
    k8s-worker-1: Get:54 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libarchive13 amd64 3.6.0-1ubuntu1.3 [369 kB]
    k8s-worker-1: Get:55 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libldap-2.5-0 amd64 2.5.18+dfsg-0ubuntu0.22.04.2 [183 kB]
    k8s-worker-1: Get:56 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libcurl3-gnutls amd64 7.81.0-1ubuntu1.20 [284 kB]
    k8s-worker-1: Get:57 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libgstreamer1.0-0 amd64 1.20.3-0ubuntu1.1 [984 kB]
    k8s-worker-1: Get:58 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libldap-common all 2.5.18+dfsg-0ubuntu0.22.04.2 [15.9 kB]
    k8s-worker-1: Get:59 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libmm-glib0 amd64 1.20.0-1~ubuntu22.04.4 [262 kB]
    k8s-worker-1: Get:60 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libmodule-scandeps-perl all 1.31-1ubuntu0.1 [30.7 kB]
    k8s-worker-1: Get:61 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-firmware all 20220329.git681281e4-0ubuntu3.36 [312 MB]
    k8s-worker-1: Get:62 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-modules-5.15.0-130-generic amd64 5.15.0-130.140 [22.7 MB]
    k8s-worker-1: Get:63 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-image-5.15.0-130-generic amd64 5.15.0-130.140 [11.6 MB]
    k8s-worker-1: Get:64 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-modules-extra-5.15.0-130-generic amd64 5.15.0-130.140 [63.9 MB]
    k8s-worker-1: Get:65 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 amd64-microcode amd64 3.20191218.1ubuntu2.3 [67.9 kB]
    k8s-worker-1: Get:66 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 intel-microcode amd64 3.20241112.0ubuntu0.22.04.1 [7,045 kB]
    k8s-worker-1: Get:67 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-image-generic amd64 5.15.0.130.128 [2,524 B]
    k8s-worker-1: Get:68 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 modemmanager amd64 1.20.0-1~ubuntu22.04.4 [1,094 kB]
    k8s-worker-1: Get:69 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 needrestart all 3.5-5ubuntu2.4 [45.2 kB]
    k8s-worker-1: Get:70 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 packagekit-tools amd64 1.2.5-2ubuntu3 [28.8 kB]
    k8s-worker-1: Get:71 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 packagekit amd64 1.2.5-2ubuntu3 [442 kB]
    k8s-worker-1: Get:72 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-configobj all 5.0.6-5ubuntu0.1 [34.9 kB]
    k8s-worker-1: Get:73 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 python3-packaging all 21.3-1 [30.7 kB]
    k8s-worker-1: Get:74 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-twisted all 22.1.0-2ubuntu2.6 [2,007 kB]
    k8s-worker-1: Get:75 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-urllib3 all 1.26.5-1~exp1ubuntu0.2 [98.3 kB]
    k8s-worker-1: Get:76 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 snapd amd64 2.66.1+22.04 [27.6 MB]
    k8s-worker-1: Get:77 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 sosreport amd64 4.7.2-0ubuntu1~22.04.2 [352 kB]
    k8s-worker-1: Get:78 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 cloud-init all 24.4-0ubuntu1~22.04.1 [565 kB]
    k8s-worker-1: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-worker-1: Fetched 481 MB in 23s (20.6 MB/s)
(Reading database ... 45178 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../base-files_12ubuntu4.7_amd64.deb ...
    k8s-worker-1: Unpacking base-files (12ubuntu4.7) over (12ubuntu4.6) ...
    k8s-worker-1: Setting up base-files (12ubuntu4.7) ...
    k8s-worker-1: Installing new version of config file /etc/issue ...
    k8s-worker-1: Installing new version of config file /etc/issue.net ...
    k8s-worker-1: Installing new version of config file /etc/lsb-release ...
    k8s-worker-1: motd-news.service is a disabled or a static unit not running, not starting it.
(Reading database ... 45178 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../libapt-pkg6.0_2.4.13_amd64.deb ...
    k8s-worker-1: Unpacking libapt-pkg6.0:amd64 (2.4.13) over (2.4.12) ...
    k8s-worker-1: Setting up libapt-pkg6.0:amd64 (2.4.13) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../archives/apt_2.4.13_amd64.deb ...
    k8s-worker-1: Unpacking apt (2.4.13) over (2.4.12) ...
    k8s-worker-1: Setting up apt (2.4.13) ...
    k8s-worker-1: apt-daily-upgrade.timer is a disabled or a static unit not running, not starting it.
    k8s-worker-1: apt-daily.timer is a disabled or a static unit not running, not starting it.
(Reading database ... 45178 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../apt-utils_2.4.13_amd64.deb ...
    k8s-worker-1: Unpacking apt-utils (2.4.13) over (2.4.12) ...
    k8s-worker-1: Preparing to unpack .../logsave_1.46.5-2ubuntu1.2_amd64.deb ...
    k8s-worker-1: Unpacking logsave (1.46.5-2ubuntu1.2) over (1.46.5-2ubuntu1.1) ...
    k8s-worker-1: Preparing to unpack .../libext2fs2_1.46.5-2ubuntu1.2_amd64.deb ...
    k8s-worker-1: Unpacking libext2fs2:amd64 (1.46.5-2ubuntu1.2) over (1.46.5-2ubuntu1.1) ...
    k8s-worker-1: Setting up libext2fs2:amd64 (1.46.5-2ubuntu1.2) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../e2fsprogs_1.46.5-2ubuntu1.2_amd64.deb ...
    k8s-worker-1: Unpacking e2fsprogs (1.46.5-2ubuntu1.2) over (1.46.5-2ubuntu1.1) ...
    k8s-worker-1: Preparing to unpack .../python3-minimal_3.10.6-1~22.04.1_amd64.deb ...
    k8s-worker-1: Unpacking python3-minimal (3.10.6-1~22.04.1) over (3.10.6-1~22.04) ...
    k8s-worker-1: Setting up python3-minimal (3.10.6-1~22.04.1) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../0-python3_3.10.6-1~22.04.1_amd64.deb ...
    k8s-worker-1: running python pre-rtupdate hooks for python3.10...
    k8s-worker-1: Unpacking python3 (3.10.6-1~22.04.1) over (3.10.6-1~22.04) ...
    k8s-worker-1: Preparing to unpack .../1-libexpat1_2.4.7-1ubuntu0.5_amd64.deb ...
    k8s-worker-1: Unpacking libexpat1:amd64 (2.4.7-1ubuntu0.5) over (2.4.7-1ubuntu0.3) ...
    k8s-worker-1: Preparing to unpack .../2-libpython3.10_3.10.12-1~22.04.7_amd64.deb ...
    k8s-worker-1: Unpacking libpython3.10:amd64 (3.10.12-1~22.04.7) over (3.10.12-1~22.04.4) ...
    k8s-worker-1: Preparing to unpack .../3-python3.10_3.10.12-1~22.04.7_amd64.deb ...
    k8s-worker-1: Unpacking python3.10 (3.10.12-1~22.04.7) over (3.10.12-1~22.04.4) ...
    k8s-worker-1: Preparing to unpack .../4-libpython3.10-stdlib_3.10.12-1~22.04.7_amd64.deb ...
    k8s-worker-1: Unpacking libpython3.10-stdlib:amd64 (3.10.12-1~22.04.7) over (3.10.12-1~22.04.4) ...
    k8s-worker-1: Preparing to unpack .../5-libssl3_3.0.2-0ubuntu1.18_amd64.deb ...
    k8s-worker-1: Unpacking libssl3:amd64 (3.0.2-0ubuntu1.18) over (3.0.2-0ubuntu1.16) ...
    k8s-worker-1: Setting up libssl3:amd64 (3.0.2-0ubuntu1.18) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../python3.10-minimal_3.10.12-1~22.04.7_amd64.deb ...
    k8s-worker-1: Unpacking python3.10-minimal (3.10.12-1~22.04.7) over (3.10.12-1~22.04.4) ...
    k8s-worker-1: Preparing to unpack .../libpython3.10-minimal_3.10.12-1~22.04.7_amd64.deb ...
    k8s-worker-1: Unpacking libpython3.10-minimal:amd64 (3.10.12-1~22.04.7) over (3.10.12-1~22.04.4) ...
    k8s-worker-1: Preparing to unpack .../libpython3-stdlib_3.10.6-1~22.04.1_amd64.deb ...
    k8s-worker-1: Unpacking libpython3-stdlib:amd64 (3.10.6-1~22.04.1) over (3.10.6-1~22.04) ...
    k8s-worker-1: Preparing to unpack .../libcom-err2_1.46.5-2ubuntu1.2_amd64.deb ...
    k8s-worker-1: Unpacking libcom-err2:amd64 (1.46.5-2ubuntu1.2) over (1.46.5-2ubuntu1.1) ...
    k8s-worker-1: Setting up libcom-err2:amd64 (1.46.5-2ubuntu1.2) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../libk5crypto3_1.19.2-2ubuntu0.4_amd64.deb ...
    k8s-worker-1: Unpacking libk5crypto3:amd64 (1.19.2-2ubuntu0.4) over (1.19.2-2ubuntu0.3) ...
    k8s-worker-1: Setting up libk5crypto3:amd64 (1.19.2-2ubuntu0.4) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../libkrb5support0_1.19.2-2ubuntu0.4_amd64.deb ...
    k8s-worker-1: Unpacking libkrb5support0:amd64 (1.19.2-2ubuntu0.4) over (1.19.2-2ubuntu0.3) ...
    k8s-worker-1: Setting up libkrb5support0:amd64 (1.19.2-2ubuntu0.4) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../libkrb5-3_1.19.2-2ubuntu0.4_amd64.deb ...
    k8s-worker-1: Unpacking libkrb5-3:amd64 (1.19.2-2ubuntu0.4) over (1.19.2-2ubuntu0.3) ...
    k8s-worker-1: Setting up libkrb5-3:amd64 (1.19.2-2ubuntu0.4) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../libgssapi-krb5-2_1.19.2-2ubuntu0.4_amd64.deb ...
    k8s-worker-1: Unpacking libgssapi-krb5-2:amd64 (1.19.2-2ubuntu0.4) over (1.19.2-2ubuntu0.3) ...
    k8s-worker-1: Setting up libgssapi-krb5-2:amd64 (1.19.2-2ubuntu0.4) ...
(Reading database ... 45178 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../00-libss2_1.46.5-2ubuntu1.2_amd64.deb ...
    k8s-worker-1: Unpacking libss2:amd64 (1.46.5-2ubuntu1.2) over (1.46.5-2ubuntu1.1) ...
    k8s-worker-1: Preparing to unpack .../01-distro-info-data_0.52ubuntu0.8_all.deb ...
    k8s-worker-1: Unpacking distro-info-data (0.52ubuntu0.8) over (0.52ubuntu0.7) ...
    k8s-worker-1: Preparing to unpack .../02-libapparmor1_3.0.4-2ubuntu2.4_amd64.deb ...
    k8s-worker-1: Unpacking libapparmor1:amd64 (3.0.4-2ubuntu2.4) over (3.0.4-2ubuntu2.3) ...
    k8s-worker-1: Preparing to unpack .../03-libglib2.0-data_2.72.4-0ubuntu2.4_all.deb ...
    k8s-worker-1: Unpacking libglib2.0-data (2.72.4-0ubuntu2.4) over (2.72.4-0ubuntu2.3) ...
    k8s-worker-1: Preparing to unpack .../04-libglib2.0-bin_2.72.4-0ubuntu2.4_amd64.deb ...
    k8s-worker-1: Unpacking libglib2.0-bin (2.72.4-0ubuntu2.4) over (2.72.4-0ubuntu2.3) ...
    k8s-worker-1: Preparing to unpack .../05-libglib2.0-0_2.72.4-0ubuntu2.4_amd64.deb ...
    k8s-worker-1: Unpacking libglib2.0-0:amd64 (2.72.4-0ubuntu2.4) over (2.72.4-0ubuntu2.3) ...
    k8s-worker-1: Preparing to unpack .../06-openssl_3.0.2-0ubuntu1.18_amd64.deb ...
    k8s-worker-1: Unpacking openssl (3.0.2-0ubuntu1.18) over (3.0.2-0ubuntu1.16) ...
    k8s-worker-1: Preparing to unpack .../07-python-apt-common_2.4.0ubuntu4_all.deb ...
    k8s-worker-1: Unpacking python-apt-common (2.4.0ubuntu4) over (2.4.0ubuntu3) ...
    k8s-worker-1: Preparing to unpack .../08-python3-apt_2.4.0ubuntu4_amd64.deb ...
    k8s-worker-1: Unpacking python3-apt (2.4.0ubuntu4) over (2.4.0ubuntu3) ...
    k8s-worker-1: Preparing to unpack .../09-python3-setuptools_59.6.0-1.2ubuntu0.22.04.2_all.deb ...
    k8s-worker-1: Unpacking python3-setuptools (59.6.0-1.2ubuntu0.22.04.2) over (59.6.0-1.2ubuntu0.22.04.1) ...
    k8s-worker-1: Preparing to unpack .../10-python3-pkg-resources_59.6.0-1.2ubuntu0.22.04.2_all.deb ...
    k8s-worker-1: Unpacking python3-pkg-resources (59.6.0-1.2ubuntu0.22.04.2) over (59.6.0-1.2ubuntu0.22.04.1) ...
    k8s-worker-1: Preparing to unpack .../11-ubuntu-pro-client-l10n_34~22.04_amd64.deb ...
    k8s-worker-1: Unpacking ubuntu-pro-client-l10n (34~22.04) over (32.3.1~22.04) ...
    k8s-worker-1: Preparing to unpack .../12-ubuntu-pro-client_34~22.04_amd64.deb ...
    k8s-worker-1: Unpacking ubuntu-pro-client (34~22.04) over (32.3.1~22.04) ...
    k8s-worker-1: Preparing to unpack .../13-ubuntu-advantage-tools_34~22.04_all.deb ...
    k8s-worker-1: Unpacking ubuntu-advantage-tools (34~22.04) over (32.3.1~22.04) ...
    k8s-worker-1: Preparing to unpack .../14-xxd_2%3a8.2.3995-1ubuntu2.21_amd64.deb ...
    k8s-worker-1: Unpacking xxd (2:8.2.3995-1ubuntu2.21) over (2:8.2.3995-1ubuntu2.17) ...
    k8s-worker-1: Preparing to unpack .../15-vim_2%3a8.2.3995-1ubuntu2.21_amd64.deb ...
    k8s-worker-1: Unpacking vim (2:8.2.3995-1ubuntu2.21) over (2:8.2.3995-1ubuntu2.17) ...
    k8s-worker-1: Preparing to unpack .../16-vim-tiny_2%3a8.2.3995-1ubuntu2.21_amd64.deb ...
    k8s-worker-1: Unpacking vim-tiny (2:8.2.3995-1ubuntu2.21) over (2:8.2.3995-1ubuntu2.17) ...
    k8s-worker-1: Preparing to unpack .../17-vim-runtime_2%3a8.2.3995-1ubuntu2.21_all.deb ...
    k8s-worker-1: Unpacking vim-runtime (2:8.2.3995-1ubuntu2.21) over (2:8.2.3995-1ubuntu2.17) ...
    k8s-worker-1: Preparing to unpack .../18-vim-common_2%3a8.2.3995-1ubuntu2.21_all.deb ...
    k8s-worker-1: Unpacking vim-common (2:8.2.3995-1ubuntu2.21) over (2:8.2.3995-1ubuntu2.17) ...
    k8s-worker-1: Preparing to unpack .../19-ubuntu-minimal_1.481.4_amd64.deb ...
    k8s-worker-1: Unpacking ubuntu-minimal (1.481.4) over (1.481.2) ...
    k8s-worker-1: Preparing to unpack .../20-apparmor_3.0.4-2ubuntu2.4_amd64.deb ...
    k8s-worker-1: Unpacking apparmor (3.0.4-2ubuntu2.4) over (3.0.4-2ubuntu2.3) ...
    k8s-worker-1: Preparing to unpack .../21-busybox-static_1%3a1.30.1-7ubuntu3.1_amd64.deb ...
    k8s-worker-1: Unpacking busybox-static (1:1.30.1-7ubuntu3.1) over (1:1.30.1-7ubuntu3) ...
    k8s-worker-1: Preparing to unpack .../22-dmidecode_3.3-3ubuntu0.2_amd64.deb ...
    k8s-worker-1: Unpacking dmidecode (3.3-3ubuntu0.2) over (3.3-3ubuntu0.1) ...
    k8s-worker-1: Preparing to unpack .../23-libpcap0.8_1.10.1-4ubuntu1.22.04.1_amd64.deb ...
    k8s-worker-1: Unpacking libpcap0.8:amd64 (1.10.1-4ubuntu1.22.04.1) over (1.10.1-4build1) ...
    k8s-worker-1: Preparing to unpack .../24-nano_6.2-1ubuntu0.1_amd64.deb ...
    k8s-worker-1: Unpacking nano (6.2-1ubuntu0.1) over (6.2-1) ...
    k8s-worker-1: Preparing to unpack .../25-python3-problem-report_2.20.11-0ubuntu82.6_all.deb ...
    k8s-worker-1: Unpacking python3-problem-report (2.20.11-0ubuntu82.6) over (2.20.11-0ubuntu82.5) ...
    k8s-worker-1: Preparing to unpack .../26-python3-apport_2.20.11-0ubuntu82.6_all.deb ...
    k8s-worker-1: Unpacking python3-apport (2.20.11-0ubuntu82.6) over (2.20.11-0ubuntu82.5) ...
    k8s-worker-1: Preparing to unpack .../27-apport_2.20.11-0ubuntu82.6_all.deb ...
    k8s-worker-1: Unpacking apport (2.20.11-0ubuntu82.6) over (2.20.11-0ubuntu82.5) ...
    k8s-worker-1: Preparing to unpack .../28-busybox-initramfs_1%3a1.30.1-7ubuntu3.1_amd64.deb ...
    k8s-worker-1: Unpacking busybox-initramfs (1:1.30.1-7ubuntu3.1) over (1:1.30.1-7ubuntu3) ...
    k8s-worker-1: Preparing to unpack .../29-libpackagekit-glib2-18_1.2.5-2ubuntu3_amd64.deb ...
    k8s-worker-1: Unpacking libpackagekit-glib2-18:amd64 (1.2.5-2ubuntu3) over (1.2.5-2ubuntu2) ...
    k8s-worker-1: Preparing to unpack .../30-gir1.2-packagekitglib-1.0_1.2.5-2ubuntu3_amd64.deb ...
    k8s-worker-1: Unpacking gir1.2-packagekitglib-1.0 (1.2.5-2ubuntu3) over (1.2.5-2ubuntu2) ...
    k8s-worker-1: Preparing to unpack .../31-libarchive13_3.6.0-1ubuntu1.3_amd64.deb ...
    k8s-worker-1: Unpacking libarchive13:amd64 (3.6.0-1ubuntu1.3) over (3.6.0-1ubuntu1.1) ...
    k8s-worker-1: Preparing to unpack .../32-libldap-2.5-0_2.5.18+dfsg-0ubuntu0.22.04.2_amd64.deb ...
    k8s-worker-1: Unpacking libldap-2.5-0:amd64 (2.5.18+dfsg-0ubuntu0.22.04.2) over (2.5.18+dfsg-0ubuntu0.22.04.1) ...
    k8s-worker-1: Preparing to unpack .../33-libcurl3-gnutls_7.81.0-1ubuntu1.20_amd64.deb ...
    k8s-worker-1: Unpacking libcurl3-gnutls:amd64 (7.81.0-1ubuntu1.20) over (7.81.0-1ubuntu1.16) ...
    k8s-worker-1: Preparing to unpack .../34-libgstreamer1.0-0_1.20.3-0ubuntu1.1_amd64.deb ...
    k8s-worker-1: Unpacking libgstreamer1.0-0:amd64 (1.20.3-0ubuntu1.1) over (1.20.3-0ubuntu1) ...
    k8s-worker-1: Preparing to unpack .../35-libldap-common_2.5.18+dfsg-0ubuntu0.22.04.2_all.deb ...
    k8s-worker-1: Unpacking libldap-common (2.5.18+dfsg-0ubuntu0.22.04.2) over (2.5.18+dfsg-0ubuntu0.22.04.1) ...
    k8s-worker-1: Preparing to unpack .../36-libmm-glib0_1.20.0-1~ubuntu22.04.4_amd64.deb ...
    k8s-worker-1: Unpacking libmm-glib0:amd64 (1.20.0-1~ubuntu22.04.4) over (1.20.0-1~ubuntu22.04.3) ...
    k8s-worker-1: Preparing to unpack .../37-libmodule-scandeps-perl_1.31-1ubuntu0.1_all.deb ...
    k8s-worker-1: Unpacking libmodule-scandeps-perl (1.31-1ubuntu0.1) over (1.31-1) ...
    k8s-worker-1: Preparing to unpack .../38-linux-firmware_20220329.git681281e4-0ubuntu3.36_all.deb ...
    k8s-worker-1: Unpacking linux-firmware (20220329.git681281e4-0ubuntu3.36) over (20220329.git681281e4-0ubuntu3.31) ...
    k8s-worker-1: Selecting previously unselected package linux-modules-5.15.0-130-generic.
    k8s-worker-1: Preparing to unpack .../39-linux-modules-5.15.0-130-generic_5.15.0-130.140_amd64.deb ...
    k8s-worker-1: Unpacking linux-modules-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: Selecting previously unselected package linux-image-5.15.0-130-generic.
    k8s-worker-1: Preparing to unpack .../40-linux-image-5.15.0-130-generic_5.15.0-130.140_amd64.deb ...
    k8s-worker-1: Unpacking linux-image-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: Selecting previously unselected package linux-modules-extra-5.15.0-130-generic.
    k8s-worker-1: Preparing to unpack .../41-linux-modules-extra-5.15.0-130-generic_5.15.0-130.140_amd64.deb ...
    k8s-worker-1: Unpacking linux-modules-extra-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: Preparing to unpack .../42-amd64-microcode_3.20191218.1ubuntu2.3_amd64.deb ...
    k8s-worker-1: Unpacking amd64-microcode (3.20191218.1ubuntu2.3) over (3.20191218.1ubuntu2.2) ...
    k8s-worker-1: Preparing to unpack .../43-intel-microcode_3.20241112.0ubuntu0.22.04.1_amd64.deb ...
    k8s-worker-1: Unpacking intel-microcode (3.20241112.0ubuntu0.22.04.1) over (3.20240514.0ubuntu0.22.04.1) ...
    k8s-worker-1: Preparing to unpack .../44-linux-image-generic_5.15.0.130.128_amd64.deb ...
    k8s-worker-1: Unpacking linux-image-generic (5.15.0.130.128) over (5.15.0.116.116) ...
    k8s-worker-1: Preparing to unpack .../45-modemmanager_1.20.0-1~ubuntu22.04.4_amd64.deb ...
    k8s-worker-1: Unpacking modemmanager (1.20.0-1~ubuntu22.04.4) over (1.20.0-1~ubuntu22.04.3) ...
    k8s-worker-1: Preparing to unpack .../46-needrestart_3.5-5ubuntu2.4_all.deb ...
    k8s-worker-1: Unpacking needrestart (3.5-5ubuntu2.4) over (3.5-5ubuntu2.1) ...
    k8s-worker-1: Preparing to unpack .../47-packagekit-tools_1.2.5-2ubuntu3_amd64.deb ...
    k8s-worker-1: Unpacking packagekit-tools (1.2.5-2ubuntu3) over (1.2.5-2ubuntu2) ...
    k8s-worker-1: Preparing to unpack .../48-packagekit_1.2.5-2ubuntu3_amd64.deb ...
    k8s-worker-1: Unpacking packagekit (1.2.5-2ubuntu3) over (1.2.5-2ubuntu2) ...
    k8s-worker-1: Preparing to unpack .../49-python3-configobj_5.0.6-5ubuntu0.1_all.deb ...
    k8s-worker-1: Unpacking python3-configobj (5.0.6-5ubuntu0.1) over (5.0.6-5) ...
    k8s-worker-1: Selecting previously unselected package python3-packaging.
    k8s-worker-1: Preparing to unpack .../50-python3-packaging_21.3-1_all.deb ...
    k8s-worker-1: Unpacking python3-packaging (21.3-1) ...
    k8s-worker-1: Preparing to unpack .../51-python3-twisted_22.1.0-2ubuntu2.6_all.deb ...
    k8s-worker-1: Unpacking python3-twisted (22.1.0-2ubuntu2.6) over (22.1.0-2ubuntu2.4) ...
    k8s-worker-1: Preparing to unpack .../52-python3-urllib3_1.26.5-1~exp1ubuntu0.2_all.deb ...
    k8s-worker-1: Unpacking python3-urllib3 (1.26.5-1~exp1ubuntu0.2) over (1.26.5-1~exp1ubuntu0.1) ...
    k8s-worker-1: Preparing to unpack .../53-snapd_2.66.1+22.04_amd64.deb ...
    k8s-worker-1: Unpacking snapd (2.66.1+22.04) over (2.63+22.04) ...
    k8s-worker-1: Preparing to unpack .../54-sosreport_4.7.2-0ubuntu1~22.04.2_amd64.deb ...
    k8s-worker-1: Unpacking sosreport (4.7.2-0ubuntu1~22.04.2) over (4.5.6-0ubuntu1~22.04.2) ...
    k8s-worker-1: Preparing to unpack .../55-cloud-init_24.4-0ubuntu1~22.04.1_all.deb ...
    k8s-worker-1: Unpacking cloud-init (24.4-0ubuntu1~22.04.1) over (24.1.3-0ubuntu1~22.04.5) ...
    k8s-worker-1: dpkg: warning: unable to delete old directory '/etc/systemd/system/sshd-keygen@.service.d': Directory not empty
    k8s-worker-1: Setting up libexpat1:amd64 (2.4.7-1ubuntu0.5) ...
    k8s-worker-1: Setting up libapparmor1:amd64 (3.0.4-2ubuntu2.4) ...
    k8s-worker-1: Setting up apt-utils (2.4.13) ...
    k8s-worker-1: Setting up linux-firmware (20220329.git681281e4-0ubuntu3.36) ...
    k8s-worker-1: update-initramfs: Generating /boot/initrd.img-5.15.0-116-generic
    k8s-worker-1: find: ‘/var/tmp/mkinitramfs_86A0do/lib/firmware’: No such file or directory
    k8s-worker-1: Setting up libarchive13:amd64 (3.6.0-1ubuntu1.3) ...
    k8s-worker-1: Setting up libglib2.0-0:amd64 (2.72.4-0ubuntu2.4) ...
    k8s-worker-1: No schema files found: doing nothing.
    k8s-worker-1: Setting up distro-info-data (0.52ubuntu0.8) ...
    k8s-worker-1: Setting up intel-microcode (3.20241112.0ubuntu0.22.04.1) ...
    k8s-worker-1: update-initramfs: deferring update (trigger activated)
    k8s-worker-1: intel-microcode: microcode will be updated at next boot
    k8s-worker-1: Setting up libpackagekit-glib2-18:amd64 (1.2.5-2ubuntu3) ...
    k8s-worker-1: Setting up amd64-microcode (3.20191218.1ubuntu2.3) ...
    k8s-worker-1: update-initramfs: deferring update (trigger activated)
    k8s-worker-1: amd64-microcode: microcode will be updated at next boot
    k8s-worker-1: Setting up libldap-common (2.5.18+dfsg-0ubuntu0.22.04.2) ...
    k8s-worker-1: Setting up libldap-2.5-0:amd64 (2.5.18+dfsg-0ubuntu0.22.04.2) ...
    k8s-worker-1: Setting up xxd (2:8.2.3995-1ubuntu2.21) ...
    k8s-worker-1: Setting up apparmor (3.0.4-2ubuntu2.4) ...
    k8s-worker-1: Reloading AppArmor profiles
    k8s-worker-1: Skipping profile in /etc/apparmor.d/disable: usr.sbin.rsyslogd
    k8s-worker-1: Setting up gir1.2-packagekitglib-1.0 (1.2.5-2ubuntu3) ...
    k8s-worker-1: Setting up libglib2.0-data (2.72.4-0ubuntu2.4) ...
    k8s-worker-1: Setting up vim-common (2:8.2.3995-1ubuntu2.21) ...
    k8s-worker-1: Setting up busybox-static (1:1.30.1-7ubuntu3.1) ...
    k8s-worker-1: Setting up libpcap0.8:amd64 (1.10.1-4ubuntu1.22.04.1) ...
    k8s-worker-1: Setting up libss2:amd64 (1.46.5-2ubuntu1.2) ...
    k8s-worker-1: Setting up libpython3.10-minimal:amd64 (3.10.12-1~22.04.7) ...
    k8s-worker-1: Setting up busybox-initramfs (1:1.30.1-7ubuntu3.1) ...
    k8s-worker-1: Setting up logsave (1.46.5-2ubuntu1.2) ...
    k8s-worker-1: Setting up nano (6.2-1ubuntu0.1) ...
    k8s-worker-1: Setting up python-apt-common (2.4.0ubuntu4) ...
    k8s-worker-1: Setting up libmm-glib0:amd64 (1.20.0-1~ubuntu22.04.4) ...
    k8s-worker-1: Setting up modemmanager (1.20.0-1~ubuntu22.04.4) ...
    k8s-worker-1: Setting up dmidecode (3.3-3ubuntu0.2) ...
    k8s-worker-1: Setting up vim-runtime (2:8.2.3995-1ubuntu2.21) ...
    k8s-worker-1: Setting up openssl (3.0.2-0ubuntu1.18) ...
    k8s-worker-1: Setting up libmodule-scandeps-perl (1.31-1ubuntu0.1) ...
    k8s-worker-1: Setting up libgstreamer1.0-0:amd64 (1.20.3-0ubuntu1.1) ...
    k8s-worker-1: Setcap worked! gst-ptp-helper is not suid!
    k8s-worker-1: Setting up snapd (2.66.1+22.04) ...
    k8s-worker-1: Installing new version of config file /etc/apparmor.d/usr.lib.snapd.snap-confine.real ...
    k8s-worker-1: snapd.failure.service is a disabled or a static unit not running, not starting it.
    k8s-worker-1: snapd.snap-repair.service is a disabled or a static unit not running, not starting it.
    k8s-worker-1: Setting up needrestart (3.5-5ubuntu2.4) ...
    k8s-worker-1: Setting up libglib2.0-bin (2.72.4-0ubuntu2.4) ...
    k8s-worker-1: Setting up e2fsprogs (1.46.5-2ubuntu1.2) ...
    k8s-worker-1: update-initramfs: deferring update (trigger activated)
    k8s-worker-1: e2scrub_all.service is a disabled or a static unit not running, not starting it.
    k8s-worker-1: Setting up libcurl3-gnutls:amd64 (7.81.0-1ubuntu1.20) ...
    k8s-worker-1: Setting up vim-tiny (2:8.2.3995-1ubuntu2.21) ...
    k8s-worker-1: Setting up python3.10-minimal (3.10.12-1~22.04.7) ...
    k8s-worker-1: Setting up libpython3.10-stdlib:amd64 (3.10.12-1~22.04.7) ...
    k8s-worker-1: Setting up packagekit (1.2.5-2ubuntu3) ...
    k8s-worker-1: Setting up libpython3-stdlib:amd64 (3.10.6-1~22.04.1) ...
    k8s-worker-1: Setting up packagekit-tools (1.2.5-2ubuntu3) ...
    k8s-worker-1: Setting up libpython3.10:amd64 (3.10.12-1~22.04.7) ...
    k8s-worker-1: Setting up vim (2:8.2.3995-1ubuntu2.21) ...
    k8s-worker-1: Setting up python3.10 (3.10.12-1~22.04.7) ...
    k8s-worker-1: Setting up python3 (3.10.6-1~22.04.1) ...
    k8s-worker-1: running python rtupdate hooks for python3.10...
    k8s-worker-1: running python post-rtupdate hooks for python3.10...
    k8s-worker-1: Setting up python3-packaging (21.3-1) ...
    k8s-worker-1: Setting up python3-configobj (5.0.6-5ubuntu0.1) ...
    k8s-worker-1: Setting up python3-twisted (22.1.0-2ubuntu2.6) ...
    k8s-worker-1: Setting up sosreport (4.7.2-0ubuntu1~22.04.2) ...
    k8s-worker-1: Setting up python3-urllib3 (1.26.5-1~exp1ubuntu0.2) ...
    k8s-worker-1: Setting up python3-pkg-resources (59.6.0-1.2ubuntu0.22.04.2) ...
    k8s-worker-1: Setting up cloud-init (24.4-0ubuntu1~22.04.1) ...
    k8s-worker-1: Installing new version of config file /etc/cloud/cloud.cfg ...
    k8s-worker-1: Installing new version of config file /etc/cloud/templates/sources.list.ubuntu.deb822.tmpl ...
    k8s-worker-1: Setting up python3-setuptools (59.6.0-1.2ubuntu0.22.04.2) ...
    k8s-worker-1: Setting up python3-problem-report (2.20.11-0ubuntu82.6) ...
    k8s-worker-1: Setting up python3-apt (2.4.0ubuntu4) ...
    k8s-worker-1: Setting up python3-apport (2.20.11-0ubuntu82.6) ...
    k8s-worker-1: Setting up ubuntu-pro-client (34~22.04) ...
    k8s-worker-1: Installing new version of config file /etc/apparmor.d/ubuntu_pro_apt_news ...
    k8s-worker-1: Installing new version of config file /etc/apt/apt.conf.d/20apt-esm-hook.conf ...
    k8s-worker-1: Setting up ubuntu-pro-client-l10n (34~22.04) ...
    k8s-worker-1: Setting up apport (2.20.11-0ubuntu82.6) ...
    k8s-worker-1: apport-autoreport.service is a disabled or a static unit, not starting it.
    k8s-worker-1: Setting up ubuntu-advantage-tools (34~22.04) ...
    k8s-worker-1: Setting up ubuntu-minimal (1.481.4) ...
    k8s-worker-1: Setting up linux-image-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: I: /boot/vmlinuz is now a symlink to vmlinuz-5.15.0-130-generic
    k8s-worker-1: I: /boot/initrd.img is now a symlink to initrd.img-5.15.0-130-generic
    k8s-worker-1: Setting up linux-modules-extra-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: Setting up linux-modules-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: Setting up linux-image-generic (5.15.0.130.128) ...
    k8s-worker-1: Processing triggers for initramfs-tools (0.140ubuntu13.4) ...
    k8s-worker-1: update-initramfs: Generating /boot/initrd.img-5.15.0-116-generic
    k8s-worker-1: find: ‘/var/tmp/mkinitramfs_aBfsJ9/lib/firmware’: No such file or directory
    k8s-worker-1: Processing triggers for libc-bin (2.35-0ubuntu3.8) ...
    k8s-worker-1: Processing triggers for rsyslog (8.2112.0-2ubuntu2.2) ...
    k8s-worker-1: Processing triggers for man-db (2.10.2-1) ...
    k8s-worker-1: Processing triggers for plymouth-theme-ubuntu-text (0.9.5+git20211018-1ubuntu3) ...
    k8s-worker-1: update-initramfs: deferring update (trigger activated)
    k8s-worker-1: Processing triggers for dbus (1.12.20-2ubuntu4.1) ...
    k8s-worker-1: Processing triggers for install-info (6.8-4build1) ...
    k8s-worker-1: Processing triggers for linux-image-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: /etc/kernel/postinst.d/dkms:
    k8s-worker-1: dkms: WARNING: Linux headers are missing, which may explain the above failures.
    k8s-worker-1:       please install the linux-headers-5.15.0-130-generic package to fix this.
    k8s-worker-1: /etc/kernel/postinst.d/initramfs-tools:
    k8s-worker-1: update-initramfs: Generating /boot/initrd.img-5.15.0-130-generic
    k8s-worker-1: find: ‘/var/tmp/mkinitramfs_FIhIJt/lib/firmware’: No such file or directory
    k8s-worker-1: /etc/kernel/postinst.d/zz-update-grub:
    k8s-worker-1: Sourcing file `/etc/default/grub'
    k8s-worker-1: Sourcing file `/etc/default/grub.d/init-select.cfg'
    k8s-worker-1: Generating grub configuration file ...
    k8s-worker-1: Found linux image: /boot/vmlinuz-5.15.0-130-generic
    k8s-worker-1: Found initrd image: /boot/initrd.img-5.15.0-130-generic
    k8s-worker-1: Found linux image: /boot/vmlinuz-5.15.0-116-generic
    k8s-worker-1: Found initrd image: /boot/initrd.img-5.15.0-116-generic
    k8s-worker-1: Warning: os-prober will not be executed to detect other bootable partitions.
    k8s-worker-1: Systems on them will not be added to the GRUB boot configuration.
    k8s-worker-1: Check GRUB_DISABLE_OS_PROBER documentation entry.
    k8s-worker-1: done
    k8s-worker-1: Processing triggers for initramfs-tools (0.140ubuntu13.4) ...
    k8s-worker-1: update-initramfs: Generating /boot/initrd.img-5.15.0-130-generic
    k8s-worker-1: find: ‘/var/tmp/mkinitramfs_GSnsth/lib/firmware’: No such file or directory
    k8s-worker-1: 
    k8s-worker-1: Pending kernel upgrade!
    k8s-worker-1:
    k8s-worker-1: Running kernel version:
    k8s-worker-1:   5.15.0-116-generic
    k8s-worker-1:
    k8s-worker-1: Diagnostics:
    k8s-worker-1:   The currently running kernel version is not the expected kernel version 5.15.0-130-generic.
    k8s-worker-1:
    k8s-worker-1: Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting. [Return]
    k8s-worker-1:
    k8s-worker-1: Services to be restarted:
    k8s-worker-1:  systemctl restart irqbalance.service
    k8s-worker-1:  systemctl restart polkit.service
    k8s-worker-1:  systemctl restart rpcbind.service
    k8s-worker-1:  systemctl restart ssh.service
    k8s-worker-1:  systemctl restart systemd-journald.service
    k8s-worker-1:  /etc/needrestart/restart.d/systemd-manager
    k8s-worker-1:  systemctl restart systemd-networkd.service
    k8s-worker-1:  systemctl restart systemd-resolved.service
    k8s-worker-1:  systemctl restart systemd-udevd.service
    k8s-worker-1:  systemctl restart udisks2.service
    k8s-worker-1: 
    k8s-worker-1: Service restarts being deferred:
    k8s-worker-1:  /etc/needrestart/restart.d/dbus.service
    k8s-worker-1:  systemctl restart networkd-dispatcher.service
    k8s-worker-1:  systemctl restart systemd-logind.service
    k8s-worker-1:  systemctl restart user@1000.service
    k8s-worker-1:
    k8s-worker-1: No containers need to be restarted.
    k8s-worker-1:
    k8s-worker-1: No user sessions are running outdated binaries.
    k8s-worker-1:
    k8s-worker-1: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    k8s-worker-1: grep: /etc/sysctl.conf  : No such file or directory
    k8s-worker-1: net.bridge.bridge-nf-call-iptables = 1
    k8s-worker-1: Rules updated
    k8s-worker-1: Rules updated (v6)
    k8s-worker-1: Rules updated
    k8s-worker-1: Rules updated (v6)
    k8s-worker-1: Rules updated
    k8s-worker-1: Rules updated (v6)
    k8s-worker-1: Rules updated
    k8s-worker-1: Rules updated (v6)
    k8s-worker-1: Rules updated
    k8s-worker-1: Rules updated (v6)
    k8s-worker-1: Rules updated
    k8s-worker-1: Rules updated (v6)
    k8s-worker-1: Rules updated
    k8s-worker-1: Rules updated (v6)
    k8s-worker-1: Rules updated
    k8s-worker-1: Rules updated (v6)
    k8s-worker-1: Rules updated
    k8s-worker-1: Rules updated (v6)
    k8s-worker-1: Rules updated
    k8s-worker-1: Rules updated (v6)
    k8s-worker-1: Rules updated
    k8s-worker-1: Rules updated (v6)
    k8s-worker-1: Skipping adding existing rule
    k8s-worker-1: Skipping adding existing rule (v6)
==> k8s-worker-1: Running provisioner: shell...
    k8s-worker-1: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-lsef1p.sh
    k8s-worker-1: 
    k8s-worker-1: WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
    k8s-worker-1:
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Building dependency tree...
    k8s-worker-1: Reading state information...
    k8s-worker-1: The following additional packages will be installed:
    k8s-worker-1:   runc
    k8s-worker-1: The following NEW packages will be installed:
    k8s-worker-1:   containerd runc
    k8s-worker-1: 0 upgraded, 2 newly installed, 0 to remove and 3 not upgraded.
    k8s-worker-1: Need to get 46.2 MB of archives.
    k8s-worker-1: After this operation, 175 MB of additional disk space will be used.
    k8s-worker-1: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 runc amd64 1.1.12-0ubuntu2~22.04.1 [8,405 kB]
    k8s-worker-1: Get:2 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 containerd amd64 1.7.12-0ubuntu2~22.04.1 [37.8 MB]
    k8s-worker-1: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-worker-1: Fetched 46.2 MB in 8s (5,491 kB/s)
    k8s-worker-1: Selecting previously unselected package runc.
(Reading database ... 52603 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../runc_1.1.12-0ubuntu2~22.04.1_amd64.deb ...
    k8s-worker-1: Unpacking runc (1.1.12-0ubuntu2~22.04.1) ...
    k8s-worker-1: Selecting previously unselected package containerd.
    k8s-worker-1: Preparing to unpack .../containerd_1.7.12-0ubuntu2~22.04.1_amd64.deb ...
    k8s-worker-1: Unpacking containerd (1.7.12-0ubuntu2~22.04.1) ...
    k8s-worker-1: Setting up runc (1.1.12-0ubuntu2~22.04.1) ...
    k8s-worker-1: Setting up containerd (1.7.12-0ubuntu2~22.04.1) ...
    k8s-worker-1: Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /lib/systemd/system/containerd.service.
    k8s-worker-1: Processing triggers for man-db (2.10.2-1) ...
    k8s-worker-1: 
    k8s-worker-1: Pending kernel upgrade!
    k8s-worker-1:
    k8s-worker-1: Running kernel version:
    k8s-worker-1:   5.15.0-116-generic
    k8s-worker-1:
    k8s-worker-1: Diagnostics:
    k8s-worker-1:   The currently running kernel version is not the expected kernel version 5.15.0-130-generic.
    k8s-worker-1:
    k8s-worker-1: Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting. [Return]
    k8s-worker-1:
    k8s-worker-1: Services to be restarted:
    k8s-worker-1:  systemctl restart irqbalance.service
    k8s-worker-1:  systemctl restart polkit.service
    k8s-worker-1:  systemctl restart rpcbind.service
    k8s-worker-1:  systemctl restart ssh.service
    k8s-worker-1:  systemctl restart systemd-journald.service
    k8s-worker-1:  /etc/needrestart/restart.d/systemd-manager
    k8s-worker-1:  systemctl restart systemd-networkd.service
    k8s-worker-1:  systemctl restart systemd-resolved.service
    k8s-worker-1:  systemctl restart systemd-udevd.service
    k8s-worker-1:  systemctl restart udisks2.service
    k8s-worker-1: 
    k8s-worker-1: Service restarts being deferred:
    k8s-worker-1:  /etc/needrestart/restart.d/dbus.service
    k8s-worker-1:  systemctl restart networkd-dispatcher.service
    k8s-worker-1:  systemctl restart systemd-logind.service
    k8s-worker-1:  systemctl restart user@1000.service
    k8s-worker-1:
    k8s-worker-1: No containers need to be restarted.
    k8s-worker-1: 
    k8s-worker-1: No user sessions are running outdated binaries.
    k8s-worker-1:
    k8s-worker-1: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    k8s-worker-1: disabled_plugins = []
    k8s-worker-1: imports = []
    k8s-worker-1: oom_score = 0
    k8s-worker-1: plugin_dir = ""
    k8s-worker-1: required_plugins = []
    k8s-worker-1: root = "/var/lib/containerd"
    k8s-worker-1: state = "/run/containerd"
    k8s-worker-1: temp = ""
    k8s-worker-1: version = 2
    k8s-worker-1: 
    k8s-worker-1: [cgroup]
    k8s-worker-1:   path = ""
    k8s-worker-1:
    k8s-worker-1: [debug]
    k8s-worker-1:   address = ""
    k8s-worker-1:   format = ""
    k8s-worker-1:   gid = 0
    k8s-worker-1:   level = ""
    k8s-worker-1:   uid = 0
    k8s-worker-1:
    k8s-worker-1: [grpc]
    k8s-worker-1:   address = "/run/containerd/containerd.sock"
    k8s-worker-1:   gid = 0
    k8s-worker-1:   max_recv_message_size = 16777216
    k8s-worker-1:   max_send_message_size = 16777216
    k8s-worker-1:   tcp_address = ""
    k8s-worker-1:   tcp_tls_ca = ""
    k8s-worker-1:   tcp_tls_cert = ""
    k8s-worker-1:   tcp_tls_key = ""
    k8s-worker-1:   uid = 0
    k8s-worker-1: 
    k8s-worker-1: [metrics]
    k8s-worker-1:   address = ""
    k8s-worker-1:   grpc_histogram = false
    k8s-worker-1:
    k8s-worker-1: [plugins]
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.gc.v1.scheduler"]
    k8s-worker-1:     deletion_threshold = 0
    k8s-worker-1:     mutation_threshold = 100
    k8s-worker-1:     pause_threshold = 0.02
    k8s-worker-1:     schedule_delay = "0s"
    k8s-worker-1:     startup_delay = "100ms"
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.grpc.v1.cri"]
    k8s-worker-1:     cdi_spec_dirs = ["/etc/cdi", "/var/run/cdi"]
    k8s-worker-1:     device_ownership_from_security_context = false
    k8s-worker-1:     disable_apparmor = false
    k8s-worker-1:     disable_cgroup = false
    k8s-worker-1:     disable_hugetlb_controller = true
    k8s-worker-1:     disable_proc_mount = false
    k8s-worker-1:     disable_tcp_service = true
    k8s-worker-1:     drain_exec_sync_io_timeout = "0s"
    k8s-worker-1:     enable_cdi = false
    k8s-worker-1:     enable_selinux = false
    k8s-worker-1:     enable_tls_streaming = false
    k8s-worker-1:     enable_unprivileged_icmp = false
    k8s-worker-1:     enable_unprivileged_ports = false
    k8s-worker-1:     ignore_image_defined_volumes = false
    k8s-worker-1:     image_pull_progress_timeout = "5m0s"
    k8s-worker-1:     max_concurrent_downloads = 3
    k8s-worker-1:     max_container_log_line_size = 16384
    k8s-worker-1:     netns_mounts_under_state_dir = false
    k8s-worker-1:     restrict_oom_score_adj = false
    k8s-worker-1:     sandbox_image = "registry.k8s.io/pause:3.8"
    k8s-worker-1:     selinux_category_range = 1024
    k8s-worker-1:     stats_collect_period = 10
    k8s-worker-1:     stream_idle_timeout = "4h0m0s"
    k8s-worker-1:     stream_server_address = "127.0.0.1"
    k8s-worker-1:     stream_server_port = "0"
    k8s-worker-1:     systemd_cgroup = false
    k8s-worker-1:     tolerate_missing_hugetlb_controller = true
    k8s-worker-1:     unset_seccomp_profile = ""
    k8s-worker-1:
    k8s-worker-1:     [plugins."io.containerd.grpc.v1.cri".cni]
    k8s-worker-1:       bin_dir = "/opt/cni/bin"
    k8s-worker-1:       conf_dir = "/etc/cni/net.d"
    k8s-worker-1:       conf_template = ""
    k8s-worker-1:       ip_pref = ""
    k8s-worker-1:       max_conf_num = 1
    k8s-worker-1:       setup_serially = false
    k8s-worker-1:
    k8s-worker-1:     [plugins."io.containerd.grpc.v1.cri".containerd]
    k8s-worker-1:       default_runtime_name = "runc"
    k8s-worker-1:       disable_snapshot_annotations = true
    k8s-worker-1:       discard_unpacked_layers = false
    k8s-worker-1:       ignore_blockio_not_enabled_errors = false
    k8s-worker-1:       ignore_rdt_not_enabled_errors = false
    k8s-worker-1:       no_pivot = false
    k8s-worker-1:       snapshotter = "overlayfs"
    k8s-worker-1:
    k8s-worker-1:       [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
    k8s-worker-1:         base_runtime_spec = ""
    k8s-worker-1:         cni_conf_dir = ""
    k8s-worker-1:         cni_max_conf_num = 0
    k8s-worker-1:         container_annotations = []
    k8s-worker-1:         pod_annotations = []
    k8s-worker-1:         privileged_without_host_devices = false
    k8s-worker-1:         privileged_without_host_devices_all_devices_allowed = false
    k8s-worker-1:         runtime_engine = ""
    k8s-worker-1:         runtime_path = ""
    k8s-worker-1:         runtime_root = ""
    k8s-worker-1:         runtime_type = ""
    k8s-worker-1:         sandbox_mode = ""
    k8s-worker-1:         snapshotter = ""
    k8s-worker-1:
    k8s-worker-1:         [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime.options]
    k8s-worker-1:
    k8s-worker-1:       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
    k8s-worker-1:
    k8s-worker-1:         [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    k8s-worker-1:           base_runtime_spec = ""
    k8s-worker-1:           cni_conf_dir = ""
    k8s-worker-1:           cni_max_conf_num = 0
    k8s-worker-1:           container_annotations = []
    k8s-worker-1:           pod_annotations = []
    k8s-worker-1:           privileged_without_host_devices = false
    k8s-worker-1:           privileged_without_host_devices_all_devices_allowed = false
    k8s-worker-1:           runtime_engine = ""
    k8s-worker-1:           runtime_path = ""
    k8s-worker-1:           runtime_root = ""
    k8s-worker-1:           runtime_type = "io.containerd.runc.v2"
    k8s-worker-1:           sandbox_mode = "podsandbox"
    k8s-worker-1:           snapshotter = ""
    k8s-worker-1:
    k8s-worker-1:           [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    k8s-worker-1:             BinaryName = ""
    k8s-worker-1:             CriuImagePath = ""
    k8s-worker-1:             CriuPath = ""
    k8s-worker-1:             CriuWorkPath = ""
    k8s-worker-1:             IoGid = 0
    k8s-worker-1:             IoUid = 0
    k8s-worker-1:             NoNewKeyring = false
    k8s-worker-1:             NoPivotRoot = false
    k8s-worker-1:             Root = ""
    k8s-worker-1:             ShimCgroup = ""
    k8s-worker-1:             SystemdCgroup = false
    k8s-worker-1:
    k8s-worker-1:       [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime]
    k8s-worker-1:         base_runtime_spec = ""
    k8s-worker-1:         cni_conf_dir = ""
    k8s-worker-1:         cni_max_conf_num = 0
    k8s-worker-1:         container_annotations = []
    k8s-worker-1:         pod_annotations = []
    k8s-worker-1:         privileged_without_host_devices = false
    k8s-worker-1:         privileged_without_host_devices_all_devices_allowed = false
    k8s-worker-1:         runtime_engine = ""
    k8s-worker-1:         runtime_path = ""
    k8s-worker-1:         runtime_root = ""
    k8s-worker-1:         runtime_type = ""
    k8s-worker-1:         sandbox_mode = ""
    k8s-worker-1:         snapshotter = ""
    k8s-worker-1:
    k8s-worker-1:         [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime.options]
    k8s-worker-1:
    k8s-worker-1:     [plugins."io.containerd.grpc.v1.cri".image_decryption]
    k8s-worker-1:       key_model = "node"
    k8s-worker-1:
    k8s-worker-1:     [plugins."io.containerd.grpc.v1.cri".registry]
    k8s-worker-1:       config_path = ""
    k8s-worker-1:
    k8s-worker-1:       [plugins."io.containerd.grpc.v1.cri".registry.auths]
    k8s-worker-1:
    k8s-worker-1:       [plugins."io.containerd.grpc.v1.cri".registry.configs]
    k8s-worker-1:
    k8s-worker-1:       [plugins."io.containerd.grpc.v1.cri".registry.headers]
    k8s-worker-1:
    k8s-worker-1:       [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
    k8s-worker-1: 
    k8s-worker-1:     [plugins."io.containerd.grpc.v1.cri".x509_key_pair_streaming]
    k8s-worker-1:       tls_cert_file = ""
    k8s-worker-1:       tls_key_file = ""
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.internal.v1.opt"]
    k8s-worker-1:     path = "/opt/containerd"
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.internal.v1.restart"]
    k8s-worker-1:     interval = "10s"
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.internal.v1.tracing"]
    k8s-worker-1:     sampling_ratio = 1.0
    k8s-worker-1:     service_name = "containerd"
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.metadata.v1.bolt"]
    k8s-worker-1:     content_sharing_policy = "shared"
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.monitor.v1.cgroups"]
    k8s-worker-1:     no_prometheus = false
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.nri.v1.nri"]
    k8s-worker-1:     disable = true
    k8s-worker-1:     disable_connections = false
    k8s-worker-1:     plugin_config_path = "/etc/nri/conf.d"
    k8s-worker-1:     plugin_path = "/opt/nri/plugins"
    k8s-worker-1:     plugin_registration_timeout = "5s"
    k8s-worker-1:     plugin_request_timeout = "2s"
    k8s-worker-1:     socket_path = "/var/run/nri/nri.sock"
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.runtime.v1.linux"]
    k8s-worker-1:     no_shim = false
    k8s-worker-1:     runtime = "runc"
    k8s-worker-1:     runtime_root = ""
    k8s-worker-1:     shim = "containerd-shim"
    k8s-worker-1:     shim_debug = false
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.runtime.v2.task"]
    k8s-worker-1:     platforms = ["linux/amd64"]
    k8s-worker-1:     sched_core = false
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.service.v1.diff-service"]
    k8s-worker-1:     default = ["walking"]
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.service.v1.tasks-service"]
    k8s-worker-1:     blockio_config_file = ""
    k8s-worker-1:     rdt_config_file = ""
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.snapshotter.v1.aufs"]
    k8s-worker-1:     root_path = ""
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.snapshotter.v1.blockfile"]
    k8s-worker-1:     fs_type = ""
    k8s-worker-1:     mount_options = []
    k8s-worker-1:     root_path = ""
    k8s-worker-1:     scratch_file = ""
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.snapshotter.v1.btrfs"]
    k8s-worker-1:     root_path = ""
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.snapshotter.v1.devmapper"]
    k8s-worker-1:     async_remove = false
    k8s-worker-1:     base_image_size = ""
    k8s-worker-1:     discard_blocks = false
    k8s-worker-1:     fs_options = ""
    k8s-worker-1:     fs_type = ""
    k8s-worker-1:     pool_name = ""
    k8s-worker-1:     root_path = ""
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.snapshotter.v1.native"]
    k8s-worker-1:     root_path = ""
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.snapshotter.v1.overlayfs"]
    k8s-worker-1:     mount_options = []
    k8s-worker-1:     root_path = ""
    k8s-worker-1:     sync_remove = false
    k8s-worker-1:     upperdir_label = false
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.snapshotter.v1.zfs"]
    k8s-worker-1:     root_path = ""
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.tracing.processor.v1.otlp"]
    k8s-worker-1:     endpoint = ""
    k8s-worker-1:     insecure = false
    k8s-worker-1:     protocol = ""
    k8s-worker-1:
    k8s-worker-1:   [plugins."io.containerd.transfer.v1.local"]
    k8s-worker-1:     config_path = ""
    k8s-worker-1:     max_concurrent_downloads = 3
    k8s-worker-1:     max_concurrent_uploaded_layers = 3
    k8s-worker-1:
    k8s-worker-1:     [[plugins."io.containerd.transfer.v1.local".unpack_config]]
    k8s-worker-1:       differ = ""
    k8s-worker-1:       platform = "linux/amd64"
    k8s-worker-1:       snapshotter = "overlayfs"
    k8s-worker-1:
    k8s-worker-1: [proxy_plugins]
    k8s-worker-1:
    k8s-worker-1: [stream_processors]
    k8s-worker-1:
    k8s-worker-1:   [stream_processors."io.containerd.ocicrypt.decoder.v1.tar"]
    k8s-worker-1:     accepts = ["application/vnd.oci.image.layer.v1.tar+encrypted"]
    k8s-worker-1:     args = ["--decryption-keys-path", "/etc/containerd/ocicrypt/keys"]
    k8s-worker-1:     env = ["OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf"]
    k8s-worker-1:     path = "ctd-decoder"
    k8s-worker-1:     returns = "application/vnd.oci.image.layer.v1.tar"
    k8s-worker-1:
    k8s-worker-1:   [stream_processors."io.containerd.ocicrypt.decoder.v1.tar.gzip"]
    k8s-worker-1:     accepts = ["application/vnd.oci.image.layer.v1.tar+gzip+encrypted"]
    k8s-worker-1:     args = ["--decryption-keys-path", "/etc/containerd/ocicrypt/keys"]
    k8s-worker-1:     env = ["OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf"]
    k8s-worker-1:     path = "ctd-decoder"
    k8s-worker-1:     returns = "application/vnd.oci.image.layer.v1.tar+gzip"
    k8s-worker-1:
    k8s-worker-1: [timeouts]
    k8s-worker-1:   "io.containerd.timeout.bolt.open" = "0s"
    k8s-worker-1:   "io.containerd.timeout.metrics.shimstats" = "2s"
    k8s-worker-1:   "io.containerd.timeout.shim.cleanup" = "5s"
    k8s-worker-1:   "io.containerd.timeout.shim.load" = "5s"
    k8s-worker-1:   "io.containerd.timeout.shim.shutdown" = "3s"
    k8s-worker-1:   "io.containerd.timeout.task.state" = "2s"
    k8s-worker-1:
    k8s-worker-1: [ttrpc]
    k8s-worker-1:   address = ""
    k8s-worker-1:   gid = 0
    k8s-worker-1:   uid = 0
    k8s-worker-1: ● containerd.service - containerd container runtime
    k8s-worker-1:      Loaded: loaded (/lib/systemd/system/containerd.service; enabled; vendor preset: enabled)
    k8s-worker-1:      Active: active (running) since Wed 2025-01-08 09:00:20 UTC; 21ms ago
    k8s-worker-1:        Docs: https://containerd.io
    k8s-worker-1:     Process: 49746 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
    k8s-worker-1:    Main PID: 49747 (containerd)
    k8s-worker-1:       Tasks: 8
    k8s-worker-1:      Memory: 15.3M
    k8s-worker-1:         CPU: 120ms
    k8s-worker-1:      CGroup: /system.slice/containerd.service
    k8s-worker-1:              └─49747 /usr/bin/containerd
    k8s-worker-1:
    k8s-worker-1: Jan 08 09:00:20 k8s-worker-1 containerd[49747]: time="2025-01-08T09:00:20.950632255Z" level=info msg=serving... address=/run/containerd/containerd.sock.ttrpc
    k8s-worker-1: Jan 08 09:00:20 k8s-worker-1 containerd[49747]: time="2025-01-08T09:00:20.951134788Z" level=info msg=serving... address=/run/containerd/containerd.sock    k8s-worker-1: Jan 08 09:00:20 k8s-worker-1 containerd[49747]: time="2025-01-08T09:00:20.951154671Z" level=info msg="Start subscribing containerd event"
    k8s-worker-1: Jan 08 09:00:20 k8s-worker-1 containerd[49747]: time="2025-01-08T09:00:20.951665934Z" level=info msg="Start recovering state"
    k8s-worker-1: Jan 08 09:00:20 k8s-worker-1 containerd[49747]: time="2025-01-08T09:00:20.951743786Z" level=info msg="Start event monitor"
    k8s-worker-1: Jan 08 09:00:20 k8s-worker-1 containerd[49747]: time="2025-01-08T09:00:20.951935694Z" level=info msg="Start snapshots syncer"
    k8s-worker-1: Jan 08 09:00:20 k8s-worker-1 containerd[49747]: time="2025-01-08T09:00:20.952017212Z" level=info msg="Start cni network conf syncer for default"       
    k8s-worker-1: Jan 08 09:00:20 k8s-worker-1 containerd[49747]: time="2025-01-08T09:00:20.952027395Z" level=info msg="Start streaming server"
    k8s-worker-1: Jan 08 09:00:20 k8s-worker-1 containerd[49747]: time="2025-01-08T09:00:20.952349168Z" level=info msg="containerd successfully booted in 0.054056s"     
    k8s-worker-1: Jan 08 09:00:20 k8s-worker-1 systemd[1]: Started containerd container runtime.
==> k8s-worker-1: Running provisioner: shell...
    k8s-worker-1: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-rseehf.sh
    k8s-worker-1: Hit:1 http://us.archive.ubuntu.com/ubuntu jammy InRelease
    k8s-worker-1: Hit:2 http://security.ubuntu.com/ubuntu jammy-security InRelease
    k8s-worker-1: Hit:3 http://us.archive.ubuntu.com/ubuntu jammy-updates InRelease
    k8s-worker-1: Hit:4 http://us.archive.ubuntu.com/ubuntu jammy-backports InRelease
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Building dependency tree...
    k8s-worker-1: Reading state information...
    k8s-worker-1: ca-certificates is already the newest version (20240203~22.04.1).
    k8s-worker-1: ca-certificates set to manually installed.
    k8s-worker-1: curl is already the newest version (7.81.0-1ubuntu1.20).
    k8s-worker-1: gpg is already the newest version (2.2.27-3ubuntu2.1).
    k8s-worker-1: gpg set to manually installed.
    k8s-worker-1: apt-transport-https is already the newest version (2.4.13).
    k8s-worker-1: 0 upgraded, 0 newly installed, 0 to remove and 3 not upgraded.
    k8s-worker-1: Directory exists
    k8s-worker-1: deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /
    k8s-worker-1: Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  InRelease [1,186 B]
    k8s-worker-1: Hit:2 http://us.archive.ubuntu.com/ubuntu jammy InRelease
    k8s-worker-1: Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  Packages [2,731 B]
    k8s-worker-1: Hit:4 http://security.ubuntu.com/ubuntu jammy-security InRelease
    k8s-worker-1: Hit:5 http://us.archive.ubuntu.com/ubuntu jammy-updates InRelease
    k8s-worker-1: Hit:6 http://us.archive.ubuntu.com/ubuntu jammy-backports InRelease
    k8s-worker-1: Fetched 3,917 B in 1s (2,956 B/s)
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Building dependency tree...
    k8s-worker-1: Reading state information...
    k8s-worker-1: The following additional packages will be installed:
    k8s-worker-1:   conntrack cri-tools kubernetes-cni
    k8s-worker-1: The following NEW packages will be installed:
    k8s-worker-1:   conntrack cri-tools kubeadm kubectl kubelet kubernetes-cni
    k8s-worker-1: 0 upgraded, 6 newly installed, 0 to remove and 3 not upgraded.
    k8s-worker-1: Need to get 92.7 MB of archives.
    k8s-worker-1: After this operation, 338 MB of additional disk space will be used.
    k8s-worker-1: Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  cri-tools 1.32.0-1.1 [16.3 MB]
    k8s-worker-1: Get:3 http://us.archive.ubuntu.com/ubuntu jammy/main amd64 conntrack amd64 1:1.4.6-2build2 [33.5 kB]
    k8s-worker-1: Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  kubeadm 1.32.0-1.1 [12.2 MB]
    k8s-worker-1: Get:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  kubectl 1.32.0-1.1 [11.3 MB]
    k8s-worker-1: Get:5 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  kubernetes-cni 1.6.0-1.1 [37.8 MB]
    k8s-worker-1: Get:6 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb  kubelet 1.32.0-1.1 [15.2 MB]
    k8s-worker-1: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-worker-1: Fetched 92.7 MB in 3s (28.2 MB/s)
    k8s-worker-1: Selecting previously unselected package conntrack.
(Reading database ... 52667 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../0-conntrack_1%3a1.4.6-2build2_amd64.deb ...
    k8s-worker-1: Unpacking conntrack (1:1.4.6-2build2) ...
    k8s-worker-1: Selecting previously unselected package cri-tools.
    k8s-worker-1: Preparing to unpack .../1-cri-tools_1.32.0-1.1_amd64.deb ...
    k8s-worker-1: Unpacking cri-tools (1.32.0-1.1) ...
    k8s-worker-1: Selecting previously unselected package kubeadm.
    k8s-worker-1: Preparing to unpack .../2-kubeadm_1.32.0-1.1_amd64.deb ...
    k8s-worker-1: Unpacking kubeadm (1.32.0-1.1) ...
    k8s-worker-1: Selecting previously unselected package kubectl.
    k8s-worker-1: Preparing to unpack .../3-kubectl_1.32.0-1.1_amd64.deb ...
    k8s-worker-1: Unpacking kubectl (1.32.0-1.1) ...
    k8s-worker-1: Selecting previously unselected package kubernetes-cni.
    k8s-worker-1: Preparing to unpack .../4-kubernetes-cni_1.6.0-1.1_amd64.deb ...
    k8s-worker-1: Unpacking kubernetes-cni (1.6.0-1.1) ...
    k8s-worker-1: Selecting previously unselected package kubelet.
    k8s-worker-1: Preparing to unpack .../5-kubelet_1.32.0-1.1_amd64.deb ...
    k8s-worker-1: Unpacking kubelet (1.32.0-1.1) ...
    k8s-worker-1: Setting up conntrack (1:1.4.6-2build2) ...
    k8s-worker-1: Setting up kubectl (1.32.0-1.1) ...
    k8s-worker-1: Setting up cri-tools (1.32.0-1.1) ...
    k8s-worker-1: Setting up kubernetes-cni (1.6.0-1.1) ...
    k8s-worker-1: Setting up kubeadm (1.32.0-1.1) ...
    k8s-worker-1: Setting up kubelet (1.32.0-1.1) ...
    k8s-worker-1: Processing triggers for man-db (2.10.2-1) ...
    k8s-worker-1: 
    k8s-worker-1: Pending kernel upgrade!
    k8s-worker-1:
    k8s-worker-1: Running kernel version:
    k8s-worker-1:   5.15.0-116-generic
    k8s-worker-1:
    k8s-worker-1: Diagnostics:
    k8s-worker-1:   The currently running kernel version is not the expected kernel version 5.15.0-130-generic.
    k8s-worker-1:
    k8s-worker-1: Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting. [Return]
    k8s-worker-1:
    k8s-worker-1: Services to be restarted:
    k8s-worker-1:  systemctl restart irqbalance.service
    k8s-worker-1:  systemctl restart polkit.service
    k8s-worker-1:  systemctl restart rpcbind.service
    k8s-worker-1:  systemctl restart ssh.service
    k8s-worker-1:  systemctl restart systemd-journald.service
    k8s-worker-1:  /etc/needrestart/restart.d/systemd-manager
    k8s-worker-1:  systemctl restart systemd-networkd.service
    k8s-worker-1:  systemctl restart systemd-resolved.service
    k8s-worker-1:  systemctl restart systemd-udevd.service
    k8s-worker-1:  systemctl restart udisks2.service
    k8s-worker-1:
    k8s-worker-1: Service restarts being deferred:
    k8s-worker-1:  /etc/needrestart/restart.d/dbus.service
    k8s-worker-1:  systemctl restart networkd-dispatcher.service
    k8s-worker-1:  systemctl restart systemd-logind.service
    k8s-worker-1:  systemctl restart user@1000.service
    k8s-worker-1:
    k8s-worker-1: No containers need to be restarted.
    k8s-worker-1:
    k8s-worker-1: No user sessions are running outdated binaries.
    k8s-worker-1:
    k8s-worker-1: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    k8s-worker-1: kubelet set on hold.
    k8s-worker-1: kubeadm set on hold.
    k8s-worker-1: kubectl set on hold.
    k8s-worker-1: 
    k8s-worker-1: WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
    k8s-worker-1:
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Building dependency tree...
    k8s-worker-1: Reading state information...
    k8s-worker-1: The following NEW packages will be installed:
    k8s-worker-1:   containernetworking-plugins
    k8s-worker-1: 0 upgraded, 1 newly installed, 0 to remove and 3 not upgraded.
    k8s-worker-1: Need to get 6,806 kB of archives.
    k8s-worker-1: After this operation, 46.2 MB of additional disk space will be used.
    k8s-worker-1: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/universe amd64 containernetworking-plugins amd64 0.9.1+ds1-1ubuntu0.1 [6,806 kB]
    k8s-worker-1: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-worker-1: Fetched 6,806 kB in 3s (2,376 kB/s)
    k8s-worker-1: Selecting previously unselected package containernetworking-plugins.
(Reading database ... 52726 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../containernetworking-plugins_0.9.1+ds1-1ubuntu0.1_amd64.deb ...
    k8s-worker-1: Unpacking containernetworking-plugins (0.9.1+ds1-1ubuntu0.1) ...
    k8s-worker-1: Setting up containernetworking-plugins (0.9.1+ds1-1ubuntu0.1) ...
    k8s-worker-1: 
    k8s-worker-1: Pending kernel upgrade!
    k8s-worker-1:
    k8s-worker-1: Running kernel version:
    k8s-worker-1:   5.15.0-116-generic
    k8s-worker-1:
    k8s-worker-1: Diagnostics:
    k8s-worker-1:   The currently running kernel version is not the expected kernel version 5.15.0-130-generic.
    k8s-worker-1:
    k8s-worker-1: Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting. [Return]
    k8s-worker-1:
    k8s-worker-1: Services to be restarted:
    k8s-worker-1:  systemctl restart irqbalance.service
    k8s-worker-1:  systemctl restart polkit.service
    k8s-worker-1:  systemctl restart rpcbind.service
    k8s-worker-1:  systemctl restart ssh.service
    k8s-worker-1:  systemctl restart systemd-journald.service
    k8s-worker-1:  /etc/needrestart/restart.d/systemd-manager
    k8s-worker-1:  systemctl restart systemd-networkd.service
    k8s-worker-1:  systemctl restart systemd-resolved.service
    k8s-worker-1:  systemctl restart systemd-udevd.service
    k8s-worker-1:  systemctl restart udisks2.service
    k8s-worker-1: 
    k8s-worker-1: Service restarts being deferred:
    k8s-worker-1:  /etc/needrestart/restart.d/dbus.service
    k8s-worker-1:  systemctl restart networkd-dispatcher.service
    k8s-worker-1:  systemctl restart systemd-logind.service
    k8s-worker-1:  systemctl restart user@1000.service
    k8s-worker-1:
    k8s-worker-1: No containers need to be restarted.
    k8s-worker-1:
    k8s-worker-1: No user sessions are running outdated binaries.
    k8s-worker-1:
    k8s-worker-1: No VM guests are running outdated hypervisor (qemu) binaries on this host.
==> k8s-worker-1: Running provisioner: shell...
    k8s-worker-1: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-djybjn.sh
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Building dependency tree...
    k8s-worker-1: Reading state information...
    k8s-worker-1: 0 upgraded, 0 newly installed, 0 to remove and 3 not upgraded.
    k8s-worker-1: Reading package lists...
    k8s-worker-1: Building dependency tree...
    k8s-worker-1: Reading state information...
    k8s-worker-1: The following packages were automatically installed and are no longer required:
    k8s-worker-1:   amd64-microcode libdbus-glib-1-2 libevdev2 libimobiledevice6 libplist3
    k8s-worker-1:   libupower-glib3 libusbmuxd6 thermald upower usbmuxd
    k8s-worker-1: Use 'sudo apt autoremove' to remove them.
    k8s-worker-1: The following additional packages will be installed:
    k8s-worker-1:   linux-image-unsigned-5.15.0-130-generic
    k8s-worker-1: Suggested packages:
    k8s-worker-1:   fdutils linux-doc | linux-source-5.15.0 linux-tools
    k8s-worker-1:   linux-headers-5.15.0-130-generic linux-modules-extra-5.15.0-130-generic
    k8s-worker-1: The following packages will be REMOVED:
    k8s-worker-1:   linux-image-5.15.0-130-generic* linux-image-generic*
    k8s-worker-1:   linux-modules-extra-5.15.0-130-generic*
    k8s-worker-1: The following NEW packages will be installed:
    k8s-worker-1:   linux-image-unsigned-5.15.0-130-generic
    k8s-worker-1: 0 upgraded, 1 newly installed, 3 to remove and 3 not upgraded.
    k8s-worker-1: Need to get 11.8 MB of archives.
    k8s-worker-1: After this operation, 352 MB disk space will be freed.
    k8s-worker-1: Get:1 http://us.archive.ubuntu.com/ubuntu jammy-updates/main amd64 linux-image-unsigned-5.15.0-130-generic amd64 5.15.0-130.140 [11.8 MB]
    k8s-worker-1: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    k8s-worker-1: Fetched 11.8 MB in 3s (3,842 kB/s)
(Reading database ... 52749 files and directories currently installed.)
    k8s-worker-1: Removing linux-image-generic (5.15.0.130.128) ...
    k8s-worker-1: Removing linux-modules-extra-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: dpkg: linux-image-5.15.0-130-generic: dependency problems, but removing anyway as you requested:
    k8s-worker-1:  linux-modules-5.15.0-130-generic depends on linux-image-5.15.0-130-generic | linux-image-unsigned-5.15.0-130-generic; however:
    k8s-worker-1:   Package linux-image-5.15.0-130-generic is to be removed.
    k8s-worker-1:   Package linux-image-unsigned-5.15.0-130-generic is not installed.
    k8s-worker-1:
    k8s-worker-1: Removing linux-image-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: I: /boot/vmlinuz is now a symlink to vmlinuz-5.15.0-116-generic
    k8s-worker-1: I: /boot/initrd.img is now a symlink to initrd.img-5.15.0-116-generic
    k8s-worker-1: /etc/kernel/postrm.d/initramfs-tools:
    k8s-worker-1: update-initramfs: Deleting /boot/initrd.img-5.15.0-130-generic
    k8s-worker-1: /etc/kernel/postrm.d/zz-update-grub:
    k8s-worker-1: Sourcing file `/etc/default/grub'
    k8s-worker-1: Sourcing file `/etc/default/grub.d/init-select.cfg'
    k8s-worker-1: Generating grub configuration file ...
    k8s-worker-1: Found linux image: /boot/vmlinuz-5.15.0-116-generic
    k8s-worker-1: Found initrd image: /boot/initrd.img-5.15.0-116-generic
    k8s-worker-1: Warning: os-prober will not be executed to detect other bootable partitions.
    k8s-worker-1: Systems on them will not be added to the GRUB boot configuration.
    k8s-worker-1: Check GRUB_DISABLE_OS_PROBER documentation entry.
    k8s-worker-1: done
    k8s-worker-1: Selecting previously unselected package linux-image-unsigned-5.15.0-130-generic.
(Reading database ... 46835 files and directories currently installed.)
    k8s-worker-1: Preparing to unpack .../linux-image-unsigned-5.15.0-130-generic_5.15.0-130.140_amd64.deb ...
    k8s-worker-1: Unpacking linux-image-unsigned-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: Setting up linux-image-unsigned-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: I: /boot/vmlinuz is now a symlink to vmlinuz-5.15.0-130-generic
    k8s-worker-1: I: /boot/initrd.img is now a symlink to initrd.img-5.15.0-130-generic
(Reading database ... 46838 files and directories currently installed.)
    k8s-worker-1: Purging configuration files for linux-image-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: I: /boot/vmlinuz is now a symlink to vmlinuz-5.15.0-116-generic
    k8s-worker-1: I: /boot/initrd.img is now a symlink to initrd.img-5.15.0-116-generic
    k8s-worker-1: /var/lib/dpkg/info/linux-image-5.15.0-130-generic.postrm ... removing pending trigger
    k8s-worker-1: rmdir: failed to remove '/lib/modules/5.15.0-130-generic': Directory not empty
    k8s-worker-1: Purging configuration files for linux-modules-extra-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: Processing triggers for linux-image-unsigned-5.15.0-130-generic (5.15.0-130.140) ...
    k8s-worker-1: 
    k8s-worker-1: Pending kernel upgrade!
    k8s-worker-1:
    k8s-worker-1: Running kernel version:
    k8s-worker-1:   5.15.0-116-generic
    k8s-worker-1:
    k8s-worker-1: Diagnostics:
    k8s-worker-1:   The currently running kernel version is not the expected kernel version 5.15.0-130-generic.
    k8s-worker-1:
    k8s-worker-1: Restarting the system to load the new kernel will not be handled automatically, so you should consider rebooting. [Return]
    k8s-worker-1: 
    k8s-worker-1: Services to be restarted:
    k8s-worker-1:  systemctl restart irqbalance.service
    k8s-worker-1:  systemctl restart polkit.service
    k8s-worker-1:  systemctl restart rpcbind.service
    k8s-worker-1:  systemctl restart ssh.service
    k8s-worker-1:  systemctl restart systemd-journald.service
    k8s-worker-1:  /etc/needrestart/restart.d/systemd-manager
    k8s-worker-1:  systemctl restart systemd-networkd.service
    k8s-worker-1:  systemctl restart systemd-resolved.service
    k8s-worker-1:  systemctl restart systemd-udevd.service
    k8s-worker-1:  systemctl restart udisks2.service
    k8s-worker-1: 
    k8s-worker-1: Service restarts being deferred:
    k8s-worker-1:  /etc/needrestart/restart.d/dbus.service
    k8s-worker-1:  systemctl restart networkd-dispatcher.service
    k8s-worker-1:  systemctl restart systemd-logind.service
    k8s-worker-1:  systemctl restart user@1000.service
    k8s-worker-1:
    k8s-worker-1: No containers need to be restarted.
    k8s-worker-1:
    k8s-worker-1: No user sessions are running outdated binaries.
    k8s-worker-1:
    k8s-worker-1: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    k8s-worker-1: Vacuuming done, freed 0B of archived journals from /run/log/journal.
    k8s-worker-1: Vacuuming done, freed 0B of archived journals from /var/log/journal/ceae310a58d54571807a719c137a7d33.
    k8s-worker-1: Vacuuming done, freed 0B of archived journals from /var/log/journal.
==> k8s-worker-1: Running provisioner: shell...
    k8s-worker-1: Running: C:/Users/07456/AppData/Local/Temp/vagrant-shell20250108-14536-5qm9fv.sh
    k8s-worker-1: [preflight] Running pre-flight checks
    k8s-worker-1: [preflight] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
    k8s-worker-1: [preflight] Use 'kubeadm init phase upload-config --config your-config.yaml' to re-upload it.
    k8s-worker-1: [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    k8s-worker-1: [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    k8s-worker-1: [kubelet-start] Starting the kubelet
    k8s-worker-1: [kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
    k8s-worker-1: [kubelet-check] The kubelet is healthy after 1.024210334s
    k8s-worker-1: [kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap
    k8s-worker-1: 
    k8s-worker-1: This node has joined the cluster:
    k8s-worker-1: * Certificate signing request was sent to apiserver and a response was received.
    k8s-worker-1: * The Kubelet was informed of the new secure connection details.
    k8s-worker-1:
    k8s-worker-1: Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
    k8s-worker-1:
    k8s-worker-1: tee: /etc/systemd/system/kubelet.service.d/10-kubeadm.conf: No such file or directory
    k8s-worker-1: Environment='KUBELET_EXTRA_ARGS=--node-ip=192.128.0.201'
PS > 
```

### vagrant status
```
PS > vagrant status
Current machine states:

k8s-master                running (virtualbox)
k8s-worker-1              running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
PS > 
```

### vagrant halt
```
PS > vagrant halt
vagrant halt  
==> k8s-worker-1: Attempting graceful shutdown of VM...
==> k8s-master: Attempting graceful shutdown of VM...
PS > vagrant status
Current machine states:

k8s-master                poweroff (virtualbox)
k8s-worker-1              poweroff (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
PS > 
```

### vagrant up
```
PS > vagrant up
Bringing machine 'master' up with 'virtualbox' provider...
Bringing machine 'worker1' up with 'virtualbox' provider...
Bringing machine 'worker2' up with 'virtualbox' provider...
==> master: Importing base box 'ubuntu/xenial64'...
==> master: Matching MAC address for NAT networking...
==> master: Checking if box 'ubuntu/xenial64' version '20210804.0.0' is up to date...
==> master: Setting the name of the VM: kubernetes-cluster_master_1628644597477_49206
==> master: Clearing any previously set network interfaces...
==> master: Preparing network interfaces based on configuration...
    master: Adapter 1: nat
    master: Adapter 2: hostonly
==> master: Forwarding ports...
    master: 22 (guest) => 2222 (host) (adapter 1)
==> master: Running 'pre-boot' VM customizations...
==> master: Booting VM...
==> master: Waiting for machine to boot. This may take a few minutes...
    master: SSH address: 127.0.0.1:2222
    master: SSH username: vagrant
    master: SSH auth method: private key
    master: Warning: Connection reset. Retrying...
    master: Warning: Connection aborted. Retrying...
    master:
    master: Vagrant insecure key detected. Vagrant will automatically replace
    master: this with a newly generated keypair for better security.
    master:
    master: Inserting generated public key within guest...
    master: Removing insecure key from the guest if it's present...
    master: Key inserted! Disconnecting and reconnecting using new SSH key...
==> master: Machine booted and ready!
==> master: Checking for guest additions in VM...
    master: The guest additions on this VM do not match the installed version of
    master: VirtualBox! In most cases this is fine, but in rare cases it can
    master: prevent things such as shared folders from working properly. If you see
    master: shared folder errors, please make sure the guest additions within the
    master: virtual machine match the version of VirtualBox you have installed on
    master: your host and reload your VM.
    master:
    master: Guest Additions Version: 5.1.38
    master: VirtualBox Version: 6.1
==> master: Setting hostname...
==> master: Configuring and enabling network interfaces...
==> master: Mounting shared folders...
    master: /vagrant => D:/workspace/kubernetes-cluster
==> master: Running provisioner: shell...
    master: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-ylxec6.sh
    master: Get:1 http://security.ubuntu.com/ubuntu xenial-security InRelease [109 kB]
    master: Hit:2 http://archive.ubuntu.com/ubuntu xenial InRelease
    master: Get:3 http://archive.ubuntu.com/ubuntu xenial-updates InRelease [109 kB]
    master: Get:4 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security InRelease [7,506 B]
    master: Get:5 http://security.ubuntu.com/ubuntu xenial-security/universe amd64 Packages [785 kB]
    master: Get:6 https://esm.ubuntu.com/infra/ubuntu xenial-infra-updates InRelease [7,475 B]
    master: Get:7 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security/main amd64 Packages [141 kB]
    master: Get:8 http://archive.ubuntu.com/ubuntu xenial-backports InRelease [107 kB]
    master: Get:9 http://archive.ubuntu.com/ubuntu xenial/universe amd64 Packages [7,532 kB]
    master: Get:10 http://security.ubuntu.com/ubuntu xenial-security/universe Translation-en [225 kB]
    master: Get:11 http://security.ubuntu.com/ubuntu xenial-security/multiverse amd64 Packages [7,864 B]
    master: Get:12 http://security.ubuntu.com/ubuntu xenial-security/multiverse Translation-en [2,672 B]
    master: Get:13 http://archive.ubuntu.com/ubuntu xenial/universe Translation-en [4,354 kB]
    master: Get:14 http://archive.ubuntu.com/ubuntu xenial/multiverse amd64 Packages [144 kB]
    master: Get:15 http://archive.ubuntu.com/ubuntu xenial/multiverse Translation-en [106 kB]
    master: Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/universe amd64 Packages [1,219 kB]
    master: Get:17 http://archive.ubuntu.com/ubuntu xenial-updates/universe Translation-en [358 kB]
    master: Get:18 http://archive.ubuntu.com/ubuntu xenial-updates/multiverse amd64 Packages [22.6 kB]
    master: Get:19 http://archive.ubuntu.com/ubuntu xenial-updates/multiverse Translation-en [8,476 B]
    master: Get:20 http://archive.ubuntu.com/ubuntu xenial-backports/main amd64 Packages [9,812 B]
    master: Get:21 http://archive.ubuntu.com/ubuntu xenial-backports/main Translation-en [4,456 B]
    master: Get:22 http://archive.ubuntu.com/ubuntu xenial-backports/universe amd64 Packages [11.3 kB]
    master: Get:23 http://archive.ubuntu.com/ubuntu xenial-backports/universe Translation-en [4,476 B]
    master: Fetched 15.3 MB in 1min 32s (164 kB/s)
    master: Reading package lists...
    master: grub-pc set on hold.
    master: grub-pc-bin set on hold.
    master: grub2-common set on hold.
    master: grub-common set on hold.
    master: E: Unable to locate package package
    master: Reading package lists...
    master: Building dependency tree...
    master: Reading state information...
    master: Calculating upgrade...
    master: 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
==> master: Running provisioner: shell...
    master: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-hhxgc4.sh
    master: Reading package lists...
    master: Building dependency tree...
    master: Reading state information...
    master: apt-transport-https is already the newest version (1.2.35).
    master: ca-certificates is already the newest version (20210119~16.04.1).
    master: curl is already the newest version (7.47.0-1ubuntu2.19).
    master: software-properties-common is already the newest version (0.96.20.10).
    master: The following additional packages will be installed:
    master:   libassuan0 libnpth0 pinentry-curses
    master: Suggested packages:
    master:   pinentry-doc
    master: The following NEW packages will be installed:
    master:   gnupg-agent libassuan0 libnpth0 pinentry-curses
    master: 0 upgraded, 4 newly installed, 0 to remove and 0 not upgraded.
    master: Need to get 314 kB of archives.
    master: After this operation, 1,202 kB of additional disk space will be used.
    master: Get:1 http://archive.ubuntu.com/ubuntu xenial/main amd64 libassuan0 amd64 2.4.2-2 [34.6 kB]
    master: Get:2 http://archive.ubuntu.com/ubuntu xenial/main amd64 pinentry-curses amd64 0.9.7-3 [31.2 kB]
    master: Get:3 http://archive.ubuntu.com/ubuntu xenial/main amd64 libnpth0 amd64 1.2-3 [7,998 B]
    master: Get:4 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 gnupg-agent amd64 2.1.11-6ubuntu2.1 [240 kB]
    master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    master: Fetched 314 kB in 3s (83.0 kB/s)
    master: Selecting previously unselected package libassuan0:amd64.
(Reading database ... 54424 files and directories currently installed.)
    master: Preparing to unpack .../libassuan0_2.4.2-2_amd64.deb ...
    master: Unpacking libassuan0:amd64 (2.4.2-2) ...
    master: Selecting previously unselected package pinentry-curses.
    master: Preparing to unpack .../pinentry-curses_0.9.7-3_amd64.deb ...
    master: Unpacking pinentry-curses (0.9.7-3) ...
    master: Selecting previously unselected package libnpth0:amd64.
    master: Preparing to unpack .../libnpth0_1.2-3_amd64.deb ...
    master: Unpacking libnpth0:amd64 (1.2-3) ...
    master: Selecting previously unselected package gnupg-agent.
    master: Preparing to unpack .../gnupg-agent_2.1.11-6ubuntu2.1_amd64.deb ...
    master: Unpacking gnupg-agent (2.1.11-6ubuntu2.1) ...
    master: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    master: Processing triggers for man-db (2.7.5-1) ...
    master: Setting up libassuan0:amd64 (2.4.2-2) ...
    master: Setting up pinentry-curses (0.9.7-3) ...
    master: Setting up libnpth0:amd64 (1.2-3) ...
    master: Setting up gnupg-agent (2.1.11-6ubuntu2.1) ...
    master: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    master: Get:1 https://download.docker.com/linux/ubuntu xenial InRelease [66.2 kB]
    master: Get:2 https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages [21.0 kB]
    master: Hit:3 http://security.ubuntu.com/ubuntu xenial-security InRelease
    master: Hit:4 http://archive.ubuntu.com/ubuntu xenial InRelease
    master: Hit:5 http://archive.ubuntu.com/ubuntu xenial-updates InRelease
    master: Hit:6 http://archive.ubuntu.com/ubuntu xenial-backports InRelease
    master: Hit:7 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security InRelease
    master: Hit:8 https://esm.ubuntu.com/infra/ubuntu xenial-infra-updates InRelease
    master: Fetched 87.2 kB in 2s (42.5 kB/s)
    master: Reading package lists...
    master: Reading package lists...
    master: Building dependency tree...
    master: Reading state information...
    master: The following additional packages will be installed:
    master:   docker-ce-rootless-extras docker-scan-plugin libltdl7 pigz
    master: Suggested packages:
    master:   aufs-tools cgroupfs-mount | cgroup-lite
    master: Recommended packages:
    master:   slirp4netns
    master: The following NEW packages will be installed:
    master:   containerd.io docker-ce docker-ce-cli docker-ce-rootless-extras
    master:   docker-scan-plugin libltdl7 pigz
    master: 0 upgraded, 7 newly installed, 0 to remove and 0 not upgraded.
    master: Need to get 107 MB of archives.
    master: After this operation, 466 MB of additional disk space will be used.
    master: Get:1 https://download.docker.com/linux/ubuntu xenial/stable amd64 containerd.io amd64 1.4.6-1 [28.0 MB]
    master: Get:2 http://archive.ubuntu.com/ubuntu xenial/universe amd64 pigz amd64 2.3.1-2 [61.1 kB]
    master: Get:3 http://archive.ubuntu.com/ubuntu xenial/main amd64 libltdl7 amd64 2.4.6-0.1 [38.3 kB]
    master: Get:4 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-ce-cli amd64 5:20.10.7~3-0~ubuntu-xenial [41.1 MB]
    master: Get:5 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-ce amd64 5:20.10.7~3-0~ubuntu-xenial [24.8 MB]
    master: Get:6 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-ce-rootless-extras amd64 5:20.10.7~3-0~ubuntu-xenial [9,052 kB]
    master: Get:7 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-scan-plugin amd64 0.8.0~ubuntu-xenial [3,889 kB]
    master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    master: Fetched 107 MB in 9s (11.5 MB/s)
    master: Selecting previously unselected package pigz.
(Reading database ... 54463 files and directories currently installed.)
    master: Preparing to unpack .../pigz_2.3.1-2_amd64.deb ...
    master: Unpacking pigz (2.3.1-2) ...
    master: Selecting previously unselected package containerd.io.
    master: Preparing to unpack .../containerd.io_1.4.6-1_amd64.deb ...
    master: Unpacking containerd.io (1.4.6-1) ...
    master: Selecting previously unselected package docker-ce-cli.
    master: Preparing to unpack .../docker-ce-cli_5%3a20.10.7~3-0~ubuntu-xenial_amd64.deb ...
    master: Unpacking docker-ce-cli (5:20.10.7~3-0~ubuntu-xenial) ...
    master: Selecting previously unselected package docker-ce.
    master: Preparing to unpack .../docker-ce_5%3a20.10.7~3-0~ubuntu-xenial_amd64.deb ...
    master: Unpacking docker-ce (5:20.10.7~3-0~ubuntu-xenial) ...
    master: Selecting previously unselected package docker-ce-rootless-extras.
    master: Preparing to unpack .../docker-ce-rootless-extras_5%3a20.10.7~3-0~ubuntu-xenial_amd64.deb ...
    master: Unpacking docker-ce-rootless-extras (5:20.10.7~3-0~ubuntu-xenial) ...
    master: Selecting previously unselected package docker-scan-plugin.
    master: Preparing to unpack .../docker-scan-plugin_0.8.0~ubuntu-xenial_amd64.deb ...
    master: Unpacking docker-scan-plugin (0.8.0~ubuntu-xenial) ...
    master: Selecting previously unselected package libltdl7:amd64.
    master: Preparing to unpack .../libltdl7_2.4.6-0.1_amd64.deb ...
    master: Unpacking libltdl7:amd64 (2.4.6-0.1) ...
    master: Processing triggers for man-db (2.7.5-1) ...
    master: Processing triggers for ureadahead (0.100.0-19.1) ...
    master: Processing triggers for systemd (229-4ubuntu21.31) ...
    master: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    master: Setting up pigz (2.3.1-2) ...
    master: Setting up containerd.io (1.4.6-1) ...
    master: Setting up docker-ce-cli (5:20.10.7~3-0~ubuntu-xenial) ...
    master: Setting up docker-ce (5:20.10.7~3-0~ubuntu-xenial) ...
    master: Setting up docker-ce-rootless-extras (5:20.10.7~3-0~ubuntu-xenial) ...
    master: Setting up docker-scan-plugin (0.8.0~ubuntu-xenial) ...
    master: Setting up libltdl7:amd64 (2.4.6-0.1) ...
    master: Processing triggers for ureadahead (0.100.0-19.1) ...
    master: Processing triggers for systemd (229-4ubuntu21.31) ...
    master: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    master: Synchronizing state of docker.service with SysV init with /lib/systemd/systemd-sysv-install...
    master: Executing /lib/systemd/systemd-sysv-install enable docker
    master: docker-ce set on hold.
==> master: Running provisioner: shell...
    master: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-14oadgv.sh
    master: Reading package lists...
    master: Building dependency tree...
    master: Reading state information...
    master: apt-transport-https is already the newest version (1.2.35).
    master: curl is already the newest version (7.47.0-1ubuntu2.19).
    master: 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
    master: deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main
    master: Hit:1 https://download.docker.com/linux/ubuntu xenial InRelease
    master: Hit:2 http://archive.ubuntu.com/ubuntu xenial InRelease
    master: Hit:3 http://security.ubuntu.com/ubuntu xenial-security InRelease
    master: Hit:4 http://archive.ubuntu.com/ubuntu xenial-updates InRelease
    master: Get:5 https://apt.kubernetes.io kubernetes-xenial InRelease [154 B]
    master: Hit:6 http://archive.ubuntu.com/ubuntu xenial-backports InRelease
    master: Hit:7 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security InRelease
    master: Get:8 https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages [48.5 kB]
    master: Hit:9 https://esm.ubuntu.com/infra/ubuntu xenial-infra-updates InRelease
    master: Fetched 57.9 kB in 1s (34.8 kB/s)
    master: Reading package lists...
    master: Reading package lists...
    master: Building dependency tree...
    master: Reading state information...
    master: The following additional packages will be installed:
    master:   conntrack cri-tools ebtables kubernetes-cni socat
    master: The following NEW packages will be installed:
    master:   conntrack cri-tools ebtables kubeadm kubectl kubelet kubernetes-cni socat
    master: 0 upgraded, 8 newly installed, 0 to remove and 0 not upgraded.
    master: Need to get 70.5 MB of archives.
    master: After this operation, 309 MB of additional disk space will be used.
    master: Get:1 http://archive.ubuntu.com/ubuntu xenial/main amd64 conntrack amd64 1:1.4.3-3 [27.3 kB]
    master: Get:2 https://apt.kubernetes.io kubernetes-xenial/main amd64 cri-tools amd64 1.13.0-01 [8,775 kB]
    master: Get:3 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 ebtables amd64 2.0.10.4-3.4ubuntu2.16.04.2 [79.9 kB]
    master: Get:4 http://archive.ubuntu.com/ubuntu xenial/universe amd64 socat amd64 1.7.3.1-1 [321 kB]
    master: Get:5 https://apt.kubernetes.io kubernetes-xenial/main amd64 kubernetes-cni amd64 0.8.7-00 [25.0 MB]
    master: Get:6 https://apt.kubernetes.io kubernetes-xenial/main amd64 kubelet amd64 1.21.2-00 [18.8 MB]
    master: Get:7 https://apt.kubernetes.io kubernetes-xenial/main amd64 kubectl amd64 1.21.2-00 [8,966 kB]
    master: Get:8 https://apt.kubernetes.io kubernetes-xenial/main amd64 kubeadm amd64 1.21.2-00 [8,547 kB]
    master: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    master: Fetched 70.5 MB in 10s (6,895 kB/s)
    master: Selecting previously unselected package conntrack.
(Reading database ... 54715 files and directories currently installed.)
    master: Preparing to unpack .../conntrack_1%3a1.4.3-3_amd64.deb ...
    master: Unpacking conntrack (1:1.4.3-3) ...
    master: Selecting previously unselected package cri-tools.
    master: Preparing to unpack .../cri-tools_1.13.0-01_amd64.deb ...
    master: Unpacking cri-tools (1.13.0-01) ...
    master: Selecting previously unselected package ebtables.
    master: Preparing to unpack .../ebtables_2.0.10.4-3.4ubuntu2.16.04.2_amd64.deb ...
    master: Unpacking ebtables (2.0.10.4-3.4ubuntu2.16.04.2) ...
    master: Selecting previously unselected package kubernetes-cni.
    master: Preparing to unpack .../kubernetes-cni_0.8.7-00_amd64.deb ...
    master: Unpacking kubernetes-cni (0.8.7-00) ...
    master: Selecting previously unselected package socat.
    master: Preparing to unpack .../socat_1.7.3.1-1_amd64.deb ...
    master: Unpacking socat (1.7.3.1-1) ...
    master: Selecting previously unselected package kubelet.
    master: Preparing to unpack .../kubelet_1.21.2-00_amd64.deb ...
    master: Unpacking kubelet (1.21.2-00) ...
    master: Selecting previously unselected package kubectl.
    master: Preparing to unpack .../kubectl_1.21.2-00_amd64.deb ...
    master: Unpacking kubectl (1.21.2-00) ...
    master: Selecting previously unselected package kubeadm.
    master: Preparing to unpack .../kubeadm_1.21.2-00_amd64.deb ...
    master: Unpacking kubeadm (1.21.2-00) ...
    master: Processing triggers for man-db (2.7.5-1) ...
    master: Processing triggers for ureadahead (0.100.0-19.1) ...
    master: Processing triggers for systemd (229-4ubuntu21.31) ...
    master: Setting up conntrack (1:1.4.3-3) ...
    master: Setting up cri-tools (1.13.0-01) ...
    master: Setting up ebtables (2.0.10.4-3.4ubuntu2.16.04.2) ...
    master: update-rc.d: warning: start and stop actions are no longer supported; falling back to defaults
    master: Setting up kubernetes-cni (0.8.7-00) ...
    master: Setting up socat (1.7.3.1-1) ...
    master: Setting up kubelet (1.21.2-00) ...
    master: Setting up kubectl (1.21.2-00) ...
    master: Setting up kubeadm (1.21.2-00) ...
    master: Processing triggers for ureadahead (0.100.0-19.1) ...
    master: Processing triggers for systemd (229-4ubuntu21.31) ...
    master: kubelet set on hold.
    master: kubeadm set on hold.
    master: kubectl set on hold.
==> master: Running provisioner: shell...
    master: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-1cttxy3.sh
==> master: Running provisioner: shell...
    master: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-aevkcq.sh
    master: I0811 01:20:22.822415    6282 version.go:254] remote version is much newer: v1.22.0; falling back to: stable-1.21
    master: [init] Using Kubernetes version: v1.21.3
    master: [preflight] Running pre-flight checks
    master:     [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
    master: [preflight] Pulling images required for setting up a Kubernetes cluster
    master: [preflight] This might take a minute or two, depending on the speed of your internet connection
    master: [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
    master: [certs] Using certificateDir folder "/etc/kubernetes/pki"
    master: [certs] Generating "ca" certificate and key
    master: [certs] Generating "apiserver" certificate and key
    master: [certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.128.0.101]
    master: [certs] Generating "apiserver-kubelet-client" certificate and key
    master: [certs] Generating "front-proxy-ca" certificate and key
    master: [certs] Generating "front-proxy-client" certificate and key
    master: [certs] Generating "etcd/ca" certificate and key
    master: [certs] Generating "etcd/server" certificate and key
    master: [certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [192.128.0.101 127.0.0.1 ::1]
    master: [certs] Generating "etcd/peer" certificate and key
    master: [certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [192.128.0.101 127.0.0.1 ::1]
    master: [certs] Generating "etcd/healthcheck-client" certificate and key
    master: [certs] Generating "apiserver-etcd-client" certificate and key
    master: [certs] Generating "sa" key and public key
    master: [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
    master: [kubeconfig] Writing "admin.conf" kubeconfig file
    master: [kubeconfig] Writing "kubelet.conf" kubeconfig file
    master: [kubeconfig] Writing "controller-manager.conf" kubeconfig file
    master: [kubeconfig] Writing "scheduler.conf" kubeconfig file
    master: [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    master: [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    master: [kubelet-start] Starting the kubelet
    master: [control-plane] Using manifest folder "/etc/kubernetes/manifests"
    master: [control-plane] Creating static Pod manifest for "kube-apiserver"
    master: [control-plane] Creating static Pod manifest for "kube-controller-manager"
    master: [control-plane] Creating static Pod manifest for "kube-scheduler"
    master: [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
    master: [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
    master: [apiclient] All control plane components are healthy after 18.003779 seconds
    master: [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
    master: [kubelet] Creating a ConfigMap "kubelet-config-1.21" in namespace kube-system with the configuration for the kubelets in the cluster
    master: [upload-certs] Skipping phase. Please see --upload-certs
    master: [mark-control-plane] Marking the node k8s-master as control-plane by adding the labels: [node-role.kubernetes.io/master(deprecated) node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
    master: [mark-control-plane] Marking the node k8s-master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
    master: [bootstrap-token] Using token: r7bo53.4sabml2rj52mv6eo
    master: [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
    master: [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
    master: [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
    master: [bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
    master: [bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
    master: [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
    master: [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
    master: [addons] Applied essential addon: CoreDNS
    master: [addons] Applied essential addon: kube-proxy
    master:
    master: Your Kubernetes control-plane has initialized successfully!
    master:
    master: To start using your cluster, you need to run the following as a regular user:
    master:
    master:   mkdir -p $HOME/.kube
    master:   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    master:   sudo chown $(id -u):$(id -g) $HOME/.kube/config
    master:
    master: Alternatively, if you are the root user, you can run:
    master:
    master:   export KUBECONFIG=/etc/kubernetes/admin.conf
    master:
    master: You should now deploy a pod network to the cluster.
    master: Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    master:   https://kubernetes.io/docs/concepts/cluster-administration/addons/
    master:
    master: Then you can join any number of worker nodes by running the following on each as root:
    master:
    master: kubeadm join 192.128.0.101:6443 --token r7bo53.4sabml2rj52mv6eo \
    master:     --discovery-token-ca-cert-hash sha256:141709108d3e04744f148e882e158c73e7f43823bd45620d9082cda04f1c1fff
    master: join.sh
    master: kubeadm join 192.128.0.101:6443 --token wp1c3n.tr0f4f4ccker0wyf --discovery-token-ca-cert-hash sha256:141709108d3e04744f148e882e158c73e7f43823bd45620d9082cda04f1c1fff
==> master: Running provisioner: shell...
    master: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-ak78oq.sh
==> master: Running provisioner: shell...
    master: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-o56oho.sh
==> master: Running provisioner: shell...
    master: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-x6rr1r.sh
    master: Warning: policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
    master: podsecuritypolicy.policy/psp.flannel.unprivileged created
    master: clusterrole.rbac.authorization.k8s.io/flannel created
    master: clusterrolebinding.rbac.authorization.k8s.io/flannel created
    master: serviceaccount/flannel created
    master: configmap/kube-flannel-cfg created
    master: daemonset.apps/kube-flannel-ds created
==> worker1: Importing base box 'ubuntu/xenial64'...
==> worker1: Matching MAC address for NAT networking...
==> worker1: Checking if box 'ubuntu/xenial64' version '20210804.0.0' is up to date...
==> worker1: Setting the name of the VM: kubernetes-cluster_worker1_1628644942856_68462
==> worker1: Fixed port collision for 22 => 2222. Now on port 2200.
==> worker1: Clearing any previously set network interfaces...
==> worker1: Preparing network interfaces based on configuration...
    worker1: Adapter 1: nat
    worker1: Adapter 2: hostonly
==> worker1: Forwarding ports...
    worker1: 22 (guest) => 2200 (host) (adapter 1)
==> worker1: Running 'pre-boot' VM customizations...
==> worker1: Booting VM...
==> worker1: Waiting for machine to boot. This may take a few minutes...
    worker1: SSH address: 127.0.0.1:2200
    worker1: SSH username: vagrant
    worker1: SSH auth method: private key
    worker1: Warning: Connection reset. Retrying...
    worker1: Warning: Connection aborted. Retrying...
    worker1:
    worker1: Vagrant insecure key detected. Vagrant will automatically replace
    worker1: this with a newly generated keypair for better security.
    worker1:
    worker1: Inserting generated public key within guest...
    worker1: Removing insecure key from the guest if it's present...
    worker1: Key inserted! Disconnecting and reconnecting using new SSH key...
==> worker1: Machine booted and ready!
==> worker1: Checking for guest additions in VM...
    worker1: The guest additions on this VM do not match the installed version of
    worker1: VirtualBox! In most cases this is fine, but in rare cases it can
    worker1: prevent things such as shared folders from working properly. If you see
    worker1: shared folder errors, please make sure the guest additions within the
    worker1: virtual machine match the version of VirtualBox you have installed on
    worker1: your host and reload your VM.
    worker1:
    worker1: Guest Additions Version: 5.1.38
    worker1: VirtualBox Version: 6.1
==> worker1: Setting hostname...
==> worker1: Configuring and enabling network interfaces...
==> worker1: Mounting shared folders...
    worker1: /vagrant => D:/workspace/kubernetes-cluster
==> worker1: Running provisioner: shell...
    worker1: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-1h1a4k3.sh
    worker1: Get:1 http://security.ubuntu.com/ubuntu xenial-security InRelease [109 kB]
    worker1: Hit:2 http://archive.ubuntu.com/ubuntu xenial InRelease
    worker1: Get:3 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security InRelease [7,506 B]
    worker1: Get:4 http://archive.ubuntu.com/ubuntu xenial-updates InRelease [109 kB]
    worker1: Get:5 https://esm.ubuntu.com/infra/ubuntu xenial-infra-updates InRelease [7,475 B]
    worker1: Get:6 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security/main amd64 Packages [141 kB]
    worker1: Get:7 http://security.ubuntu.com/ubuntu xenial-security/universe amd64 Packages [785 kB]
    worker1: Get:8 http://archive.ubuntu.com/ubuntu xenial-backports InRelease [107 kB]
    worker1: Get:9 http://archive.ubuntu.com/ubuntu xenial/universe amd64 Packages [7,532 kB]
    worker1: Get:10 http://security.ubuntu.com/ubuntu xenial-security/universe Translation-en [225 kB]
    worker1: Get:11 http://security.ubuntu.com/ubuntu xenial-security/multiverse amd64 Packages [7,864 B]
    worker1: Get:12 http://security.ubuntu.com/ubuntu xenial-security/multiverse Translation-en [2,672 B]
    worker1: Get:13 http://archive.ubuntu.com/ubuntu xenial/universe Translation-en [4,354 kB]
    worker1: Get:14 http://archive.ubuntu.com/ubuntu xenial/multiverse amd64 Packages [144 kB]
    worker1: Get:15 http://archive.ubuntu.com/ubuntu xenial/multiverse Translation-en [106 kB]
    worker1: Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/universe amd64 Packages [1,219 kB]
    worker1: Get:17 http://archive.ubuntu.com/ubuntu xenial-updates/universe Translation-en [358 kB]
    worker1: Get:18 http://archive.ubuntu.com/ubuntu xenial-updates/multiverse amd64 Packages [22.6 kB]
    worker1: Get:19 http://archive.ubuntu.com/ubuntu xenial-updates/multiverse Translation-en [8,476 B]
    worker1: Get:20 http://archive.ubuntu.com/ubuntu xenial-backports/main amd64 Packages [9,812 B]
    worker1: Get:21 http://archive.ubuntu.com/ubuntu xenial-backports/main Translation-en [4,456 B]
    worker1: Get:22 http://archive.ubuntu.com/ubuntu xenial-backports/universe amd64 Packages [11.3 kB]
    worker1: Get:23 http://archive.ubuntu.com/ubuntu xenial-backports/universe Translation-en [4,476 B]
    worker1: Fetched 15.3 MB in 1min 30s (168 kB/s)
    worker1: Reading package lists...
    worker1: grub-pc set on hold.
    worker1: grub-pc-bin set on hold.
    worker1: grub2-common set on hold.
    worker1: grub-common set on hold.
    worker1: E: Unable to locate package package
    worker1: Reading package lists...
    worker1: Building dependency tree...
    worker1: Reading state information...
    worker1: Calculating upgrade...
    worker1: 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
==> worker1: Running provisioner: shell...
    worker1: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-1gmv03x.sh
    worker1: Reading package lists...
    worker1: Building dependency tree...
    worker1: Reading state information...
    worker1: apt-transport-https is already the newest version (1.2.35).
    worker1: ca-certificates is already the newest version (20210119~16.04.1).
    worker1: curl is already the newest version (7.47.0-1ubuntu2.19).
    worker1: software-properties-common is already the newest version (0.96.20.10).
    worker1: The following additional packages will be installed:
    worker1:   libassuan0 libnpth0 pinentry-curses
    worker1: Suggested packages:
    worker1:   pinentry-doc
    worker1: The following NEW packages will be installed:
    worker1:   gnupg-agent libassuan0 libnpth0 pinentry-curses
    worker1: 0 upgraded, 4 newly installed, 0 to remove and 0 not upgraded.
    worker1: Need to get 314 kB of archives.
    worker1: After this operation, 1,202 kB of additional disk space will be used.
    worker1: Get:1 http://archive.ubuntu.com/ubuntu xenial/main amd64 libassuan0 amd64 2.4.2-2 [34.6 kB]
    worker1: Get:2 http://archive.ubuntu.com/ubuntu xenial/main amd64 pinentry-curses amd64 0.9.7-3 [31.2 kB]
    worker1: Get:3 http://archive.ubuntu.com/ubuntu xenial/main amd64 libnpth0 amd64 1.2-3 [7,998 B]
    worker1: Get:4 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 gnupg-agent amd64 2.1.11-6ubuntu2.1 [240 kB]
    worker1: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    worker1: Fetched 314 kB in 2s (128 kB/s)
    worker1: Selecting previously unselected package libassuan0:amd64.
(Reading database ... 54424 files and directories currently installed.)
    worker1: Preparing to unpack .../libassuan0_2.4.2-2_amd64.deb ...
    worker1: Unpacking libassuan0:amd64 (2.4.2-2) ...
    worker1: Selecting previously unselected package pinentry-curses.
    worker1: Preparing to unpack .../pinentry-curses_0.9.7-3_amd64.deb ...
    worker1: Unpacking pinentry-curses (0.9.7-3) ...
    worker1: Selecting previously unselected package libnpth0:amd64.
    worker1: Preparing to unpack .../libnpth0_1.2-3_amd64.deb ...
    worker1: Unpacking libnpth0:amd64 (1.2-3) ...
    worker1: Selecting previously unselected package gnupg-agent.
    worker1: Preparing to unpack .../gnupg-agent_2.1.11-6ubuntu2.1_amd64.deb ...
    worker1: Unpacking gnupg-agent (2.1.11-6ubuntu2.1) ...
    worker1: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    worker1: Processing triggers for man-db (2.7.5-1) ...
    worker1: Setting up libassuan0:amd64 (2.4.2-2) ...
    worker1: Setting up pinentry-curses (0.9.7-3) ...
    worker1: Setting up libnpth0:amd64 (1.2-3) ...
    worker1: Setting up gnupg-agent (2.1.11-6ubuntu2.1) ...
    worker1: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    worker1: Get:1 https://download.docker.com/linux/ubuntu xenial InRelease [66.2 kB]
    worker1: Get:2 https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages [21.0 kB]
    worker1: Get:3 http://security.ubuntu.com/ubuntu xenial-security InRelease [109 kB]
    worker1: Hit:4 http://archive.ubuntu.com/ubuntu xenial InRelease
    worker1: Hit:5 http://archive.ubuntu.com/ubuntu xenial-updates InRelease
    worker1: Hit:6 http://archive.ubuntu.com/ubuntu xenial-backports InRelease
    worker1: Hit:7 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security InRelease
    worker1: Hit:8 https://esm.ubuntu.com/infra/ubuntu xenial-infra-updates InRelease
    worker1: Fetched 196 kB in 1s (98.2 kB/s)
    worker1: Reading package lists...
    worker1: Reading package lists...
    worker1: Building dependency tree...
    worker1: Reading state information...
    worker1: The following additional packages will be installed:
    worker1:   docker-ce-rootless-extras docker-scan-plugin libltdl7 pigz
    worker1: Suggested packages:
    worker1:   aufs-tools cgroupfs-mount | cgroup-lite
    worker1: Recommended packages:
    worker1:   slirp4netns
    worker1: The following NEW packages will be installed:
    worker1:   containerd.io docker-ce docker-ce-cli docker-ce-rootless-extras
    worker1:   docker-scan-plugin libltdl7 pigz
    worker1: 0 upgraded, 7 newly installed, 0 to remove and 0 not upgraded.
    worker1: Need to get 107 MB of archives.
    worker1: After this operation, 466 MB of additional disk space will be used.
    worker1: Get:1 https://download.docker.com/linux/ubuntu xenial/stable amd64 containerd.io amd64 1.4.6-1 [28.0 MB]
    worker1: Get:2 http://archive.ubuntu.com/ubuntu xenial/universe amd64 pigz amd64 2.3.1-2 [61.1 kB]
    worker1: Get:3 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-ce-cli amd64 5:20.10.7~3-0~ubuntu-xenial [41.1 MB]
    worker1: Get:4 http://archive.ubuntu.com/ubuntu xenial/main amd64 libltdl7 amd64 2.4.6-0.1 [38.3 kB]
    worker1: Get:5 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-ce amd64 5:20.10.7~3-0~ubuntu-xenial [24.8 MB]    worker1: Get:6 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-ce-rootless-extras amd64 5:20.10.7~3-0~ubuntu-xenial [9,052 kB]
    worker1: Get:7 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-scan-plugin amd64 0.8.0~ubuntu-xenial [3,889 kB]
    worker1: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    worker1: Fetched 107 MB in 9s (11.4 MB/s)
    worker1: Selecting previously unselected package pigz.
(Reading database ... 54463 files and directories currently installed.)
    worker1: Preparing to unpack .../pigz_2.3.1-2_amd64.deb ...
    worker1: Unpacking pigz (2.3.1-2) ...
    worker1: Selecting previously unselected package containerd.io.
    worker1: Preparing to unpack .../containerd.io_1.4.6-1_amd64.deb ...
    worker1: Unpacking containerd.io (1.4.6-1) ...
    worker1: Selecting previously unselected package docker-ce-cli.
    worker1: Preparing to unpack .../docker-ce-cli_5%3a20.10.7~3-0~ubuntu-xenial_amd64.deb ...
    worker1: Unpacking docker-ce-cli (5:20.10.7~3-0~ubuntu-xenial) ...
    worker1: Selecting previously unselected package docker-ce.
    worker1: Preparing to unpack .../docker-ce_5%3a20.10.7~3-0~ubuntu-xenial_amd64.deb ...
    worker1: Unpacking docker-ce (5:20.10.7~3-0~ubuntu-xenial) ...
    worker1: Selecting previously unselected package docker-ce-rootless-extras.
    worker1: Preparing to unpack .../docker-ce-rootless-extras_5%3a20.10.7~3-0~ubuntu-xenial_amd64.deb ...
    worker1: Unpacking docker-ce-rootless-extras (5:20.10.7~3-0~ubuntu-xenial) ...
    worker1: Selecting previously unselected package docker-scan-plugin.
    worker1: Preparing to unpack .../docker-scan-plugin_0.8.0~ubuntu-xenial_amd64.deb ...
    worker1: Unpacking docker-scan-plugin (0.8.0~ubuntu-xenial) ...
    worker1: Selecting previously unselected package libltdl7:amd64.
    worker1: Preparing to unpack .../libltdl7_2.4.6-0.1_amd64.deb ...
    worker1: Unpacking libltdl7:amd64 (2.4.6-0.1) ...
    worker1: Processing triggers for man-db (2.7.5-1) ...
    worker1: Processing triggers for ureadahead (0.100.0-19.1) ...
    worker1: Processing triggers for systemd (229-4ubuntu21.31) ...
    worker1: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    worker1: Setting up pigz (2.3.1-2) ...
    worker1: Setting up containerd.io (1.4.6-1) ...
    worker1: Setting up docker-ce-cli (5:20.10.7~3-0~ubuntu-xenial) ...
    worker1: Setting up docker-ce (5:20.10.7~3-0~ubuntu-xenial) ...
    worker1: Setting up docker-ce-rootless-extras (5:20.10.7~3-0~ubuntu-xenial) ...
    worker1: Setting up docker-scan-plugin (0.8.0~ubuntu-xenial) ...
    worker1: Setting up libltdl7:amd64 (2.4.6-0.1) ...
    worker1: Processing triggers for ureadahead (0.100.0-19.1) ...
    worker1: Processing triggers for systemd (229-4ubuntu21.31) ...
    worker1: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    worker1: Synchronizing state of docker.service with SysV init with /lib/systemd/systemd-sysv-install...
    worker1: Executing /lib/systemd/systemd-sysv-install enable docker
    worker1: docker-ce set on hold.
==> worker1: Running provisioner: shell...
    worker1: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-1v1tk09.sh
    worker1: Reading package lists...
    worker1: Building dependency tree...
    worker1: Reading state information...
    worker1: apt-transport-https is already the newest version (1.2.35).
    worker1: curl is already the newest version (7.47.0-1ubuntu2.19).
    worker1: 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
    worker1: deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main
    worker1: Hit:1 https://download.docker.com/linux/ubuntu xenial InRelease
    worker1: Get:2 http://security.ubuntu.com/ubuntu xenial-security InRelease [109 kB]
    worker1: Hit:3 http://archive.ubuntu.com/ubuntu xenial InRelease
    worker1: Hit:4 http://archive.ubuntu.com/ubuntu xenial-updates InRelease
    worker1: Get:5 https://apt.kubernetes.io kubernetes-xenial InRelease [154 B]
    worker1: Hit:6 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security InRelease
    worker1: Hit:7 http://archive.ubuntu.com/ubuntu xenial-backports InRelease
    worker1: Hit:8 https://esm.ubuntu.com/infra/ubuntu xenial-infra-updates InRelease
    worker1: Get:9 https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages [48.5 kB]
    worker1: Fetched 167 kB in 1s (86.0 kB/s)
    worker1: Reading package lists...
    worker1: Reading package lists...
    worker1: Building dependency tree...
    worker1: Reading state information...
    worker1: The following additional packages will be installed:
    worker1:   conntrack cri-tools ebtables kubernetes-cni socat
    worker1: The following NEW packages will be installed:
    worker1:   conntrack cri-tools ebtables kubeadm kubectl kubelet kubernetes-cni socat
    worker1: 0 upgraded, 8 newly installed, 0 to remove and 0 not upgraded.
    worker1: Need to get 70.5 MB of archives.
    worker1: After this operation, 309 MB of additional disk space will be used.
    worker1: Get:1 http://archive.ubuntu.com/ubuntu xenial/main amd64 conntrack amd64 1:1.4.3-3 [27.3 kB]
    worker1: Get:2 https://apt.kubernetes.io kubernetes-xenial/main amd64 cri-tools amd64 1.13.0-01 [8,775 kB]
    worker1: Get:3 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 ebtables amd64 2.0.10.4-3.4ubuntu2.16.04.2 [79.9 kB]
    worker1: Get:4 http://archive.ubuntu.com/ubuntu xenial/universe amd64 socat amd64 1.7.3.1-1 [321 kB]
    worker1: Get:5 https://apt.kubernetes.io kubernetes-xenial/main amd64 kubernetes-cni amd64 0.8.7-00 [25.0 MB]
    worker1: Get:6 https://apt.kubernetes.io kubernetes-xenial/main amd64 kubelet amd64 1.21.2-00 [18.8 MB]
    worker1: Get:7 https://apt.kubernetes.io kubernetes-xenial/main amd64 kubectl amd64 1.21.2-00 [8,966 kB]
    worker1: Get:8 https://apt.kubernetes.io kubernetes-xenial/main amd64 kubeadm amd64 1.21.2-00 [8,547 kB]
    worker1: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    worker1: Fetched 70.5 MB in 9s (7,162 kB/s)
    worker1: Selecting previously unselected package conntrack.
(Reading database ... 54715 files and directories currently installed.)
    worker1: Preparing to unpack .../conntrack_1%3a1.4.3-3_amd64.deb ...
    worker1: Unpacking conntrack (1:1.4.3-3) ...
    worker1: Selecting previously unselected package cri-tools.
    worker1: Preparing to unpack .../cri-tools_1.13.0-01_amd64.deb ...
    worker1: Unpacking cri-tools (1.13.0-01) ...
    worker1: Selecting previously unselected package ebtables.
    worker1: Preparing to unpack .../ebtables_2.0.10.4-3.4ubuntu2.16.04.2_amd64.deb ...
    worker1: Unpacking ebtables (2.0.10.4-3.4ubuntu2.16.04.2) ...
    worker1: Selecting previously unselected package kubernetes-cni.
    worker1: Preparing to unpack .../kubernetes-cni_0.8.7-00_amd64.deb ...
    worker1: Unpacking kubernetes-cni (0.8.7-00) ...
    worker1: Selecting previously unselected package socat.
    worker1: Preparing to unpack .../socat_1.7.3.1-1_amd64.deb ...
    worker1: Unpacking socat (1.7.3.1-1) ...
    worker1: Selecting previously unselected package kubelet.
    worker1: Preparing to unpack .../kubelet_1.21.2-00_amd64.deb ...
    worker1: Unpacking kubelet (1.21.2-00) ...
    worker1: Selecting previously unselected package kubectl.
    worker1: Preparing to unpack .../kubectl_1.21.2-00_amd64.deb ...
    worker1: Unpacking kubectl (1.21.2-00) ...
    worker1: Selecting previously unselected package kubeadm.
    worker1: Preparing to unpack .../kubeadm_1.21.2-00_amd64.deb ...
    worker1: Unpacking kubeadm (1.21.2-00) ...
    worker1: Processing triggers for man-db (2.7.5-1) ...
    worker1: Processing triggers for ureadahead (0.100.0-19.1) ...
    worker1: Processing triggers for systemd (229-4ubuntu21.31) ...
    worker1: Setting up conntrack (1:1.4.3-3) ...
    worker1: Setting up cri-tools (1.13.0-01) ...
    worker1: Setting up ebtables (2.0.10.4-3.4ubuntu2.16.04.2) ...
    worker1: update-rc.d: warning: start and stop actions are no longer supported; falling back to defaults
    worker1: Setting up kubernetes-cni (0.8.7-00) ...
    worker1: Setting up socat (1.7.3.1-1) ...
    worker1: Setting up kubelet (1.21.2-00) ...
    worker1: Setting up kubectl (1.21.2-00) ...
    worker1: Setting up kubeadm (1.21.2-00) ...
    worker1: Processing triggers for ureadahead (0.100.0-19.1) ...
    worker1: Processing triggers for systemd (229-4ubuntu21.31) ...
    worker1: kubelet set on hold.
    worker1: kubeadm set on hold.
    worker1: kubectl set on hold.
==> worker1: Running provisioner: shell...
    worker1: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-w50rdj.sh
==> worker1: Running provisioner: shell...
    worker1: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-gj60h8.sh
    worker1: [preflight] Running pre-flight checks
    worker1:    [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
    worker1: [preflight] Reading configuration from the cluster...
    worker1: [preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
    worker1: [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    worker1: [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    worker1: [kubelet-start] Starting the kubelet
    worker1: [kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...
    worker1:
    worker1: This node has joined the cluster:
    worker1: * Certificate signing request was sent to apiserver and a response was received.
    worker1: * The Kubelet was informed of the new secure connection details.
    worker1:
    worker1: Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
    worker1:
    worker1: Environment='KUBELET_EXTRA_ARGS=--node-ip=192.128.0.201'
==> worker2: Importing base box 'ubuntu/xenial64'...
==> worker2: Matching MAC address for NAT networking...
==> worker2: Checking if box 'ubuntu/xenial64' version '20210804.0.0' is up to date...
==> worker2: Setting the name of the VM: kubernetes-cluster_worker2_1628645199933_92774
==> worker2: Fixed port collision for 22 => 2222. Now on port 2201.
==> worker2: Clearing any previously set network interfaces...
==> worker2: Preparing network interfaces based on configuration...
    worker2: Adapter 1: nat
    worker2: Adapter 2: hostonly
==> worker2: Forwarding ports...
    worker2: 22 (guest) => 2201 (host) (adapter 1)
==> worker2: Running 'pre-boot' VM customizations...
==> worker2: Booting VM...
==> worker2: Waiting for machine to boot. This may take a few minutes...
    worker2: SSH address: 127.0.0.1:2201
    worker2: SSH username: vagrant
    worker2: SSH auth method: private key
    worker2:
    worker2: Vagrant insecure key detected. Vagrant will automatically replace
    worker2: this with a newly generated keypair for better security.
    worker2:
    worker2: Inserting generated public key within guest...
    worker2: Removing insecure key from the guest if it's present...
    worker2: Key inserted! Disconnecting and reconnecting using new SSH key...
==> worker2: Machine booted and ready!
==> worker2: Checking for guest additions in VM...
    worker2: The guest additions on this VM do not match the installed version of
    worker2: VirtualBox! In most cases this is fine, but in rare cases it can
    worker2: prevent things such as shared folders from working properly. If you see
    worker2: shared folder errors, please make sure the guest additions within the
    worker2: virtual machine match the version of VirtualBox you have installed on
    worker2: your host and reload your VM.
    worker2:
    worker2: Guest Additions Version: 5.1.38
    worker2: VirtualBox Version: 6.1
==> worker2: Setting hostname...
==> worker2: Configuring and enabling network interfaces...
==> worker2: Mounting shared folders...
    worker2: /vagrant => D:/workspace/kubernetes-cluster
==> worker2: Running provisioner: shell...
    worker2: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-x1j48k.sh
    worker2: Get:1 http://security.ubuntu.com/ubuntu xenial-security InRelease [109 kB]
    worker2: Hit:2 http://archive.ubuntu.com/ubuntu xenial InRelease
    worker2: Get:3 http://archive.ubuntu.com/ubuntu xenial-updates InRelease [109 kB]
    worker2: Get:4 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security InRelease [7506 B]
    worker2: Get:5 https://esm.ubuntu.com/infra/ubuntu xenial-infra-updates InRelease [7475 B]
    worker2: Get:6 http://security.ubuntu.com/ubuntu xenial-security/universe amd64 Packages [785 kB]
    worker2: Get:7 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security/main amd64 Packages [141 kB]
    worker2: Get:8 http://archive.ubuntu.com/ubuntu xenial-backports InRelease [107 kB]
    worker2: Get:9 http://archive.ubuntu.com/ubuntu xenial/universe amd64 Packages [7532 kB]
    worker2: Get:10 http://security.ubuntu.com/ubuntu xenial-security/universe Translation-en [225 kB]
    worker2: Get:11 http://security.ubuntu.com/ubuntu xenial-security/multiverse amd64 Packages [7864 B]
    worker2: Get:12 http://security.ubuntu.com/ubuntu xenial-security/multiverse Translation-en [2672 B]
    worker2: Get:13 http://archive.ubuntu.com/ubuntu xenial/universe Translation-en [4354 kB]
    worker2: Get:14 http://archive.ubuntu.com/ubuntu xenial/multiverse amd64 Packages [144 kB]
    worker2: Get:15 http://archive.ubuntu.com/ubuntu xenial/multiverse Translation-en [106 kB]
    worker2: Get:16 http://archive.ubuntu.com/ubuntu xenial-updates/universe amd64 Packages [1219 kB]
    worker2: Get:17 http://archive.ubuntu.com/ubuntu xenial-updates/universe Translation-en [358 kB]
    worker2: Get:18 http://archive.ubuntu.com/ubuntu xenial-updates/multiverse amd64 Packages [22.6 kB]
    worker2: Get:19 http://archive.ubuntu.com/ubuntu xenial-updates/multiverse Translation-en [8476 B]
    worker2: Get:20 http://archive.ubuntu.com/ubuntu xenial-backports/main amd64 Packages [9812 B]
    worker2: Get:21 http://archive.ubuntu.com/ubuntu xenial-backports/main Translation-en [4456 B]
    worker2: Get:22 http://archive.ubuntu.com/ubuntu xenial-backports/universe amd64 Packages [11.3 kB]
    worker2: Get:23 http://archive.ubuntu.com/ubuntu xenial-backports/universe Translation-en [4476 B]
    worker2: Fetched 15.3 MB in 1min 36s (159 kB/s)
    worker2: Reading package lists...
    worker2: grub-pc set on hold.
    worker2: grub-pc-bin set on hold.
    worker2: grub2-common set on hold.
    worker2: grub-common set on hold.
    worker2: E: Unable to locate package package
    worker2: Reading package lists...
    worker2: Building dependency tree...
    worker2: Reading state information...
    worker2: Calculating upgrade...
    worker2:
    worker2: *The following packages could receive security updates with UA Infra: ESM service enabled:
    worker2:   libpam0g linux-headers-generic libpam-modules libsystemd0 openssh-sftp-server udev libpam-runtime isc-dhcp-common libx11-6 libudev1 apport python3-apport linux-virtual systemd-sysv liblz4-1 libpam-systemd systemd libpam-modules-bin openssh-server libx11-data openssh-client linux-headers-virtual libxml2 linux-image-virtual isc-dhcp-client python3-problem-report
    worker2: Learn more about UA Infra: ESM service for Ubuntu 16.04 at https://ubuntu.com/16-04
    worker2:
    worker2: Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
    worker2: applicable law.
    worker2:
    worker2: 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
==> worker2: Running provisioner: shell...
    worker2: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-i8156d.sh
    worker2: Reading package lists...
    worker2: Building dependency tree...
    worker2: Reading state information...
    worker2: apt-transport-https is already the newest version (1.2.35).
    worker2: ca-certificates is already the newest version (20210119~16.04.1).
    worker2: curl is already the newest version (7.47.0-1ubuntu2.19).
    worker2: software-properties-common is already the newest version (0.96.20.10).
    worker2: The following additional packages will be installed:
    worker2:   libassuan0 libnpth0 pinentry-curses
    worker2: Suggested packages:
    worker2:   pinentry-doc
    worker2: The following NEW packages will be installed:
    worker2:   gnupg-agent libassuan0 libnpth0 pinentry-curses
    worker2: 0 upgraded, 4 newly installed, 0 to remove and 0 not upgraded.
    worker2: Need to get 314 kB of archives.
    worker2: After this operation, 1,202 kB of additional disk space will be used.
    worker2: Get:1 http://archive.ubuntu.com/ubuntu xenial/main amd64 libassuan0 amd64 2.4.2-2 [34.6 kB]
    worker2: Get:2 http://archive.ubuntu.com/ubuntu xenial/main amd64 pinentry-curses amd64 0.9.7-3 [31.2 kB]
    worker2: Get:3 http://archive.ubuntu.com/ubuntu xenial/main amd64 libnpth0 amd64 1.2-3 [7,998 B]
    worker2: Get:4 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 gnupg-agent amd64 2.1.11-6ubuntu2.1 [240 kB]
    worker2: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    worker2: Fetched 314 kB in 3s (89.8 kB/s)
    worker2: Selecting previously unselected package libassuan0:amd64.
(Reading database ... 54424 files and directories currently installed.)
    worker2: Preparing to unpack .../libassuan0_2.4.2-2_amd64.deb ...
    worker2: Unpacking libassuan0:amd64 (2.4.2-2) ...
    worker2: Selecting previously unselected package pinentry-curses.
    worker2: Preparing to unpack .../pinentry-curses_0.9.7-3_amd64.deb ...
    worker2: Unpacking pinentry-curses (0.9.7-3) ...
    worker2: Selecting previously unselected package libnpth0:amd64.
    worker2: Preparing to unpack .../libnpth0_1.2-3_amd64.deb ...
    worker2: Unpacking libnpth0:amd64 (1.2-3) ...
    worker2: Selecting previously unselected package gnupg-agent.
    worker2: Preparing to unpack .../gnupg-agent_2.1.11-6ubuntu2.1_amd64.deb ...
    worker2: Unpacking gnupg-agent (2.1.11-6ubuntu2.1) ...
    worker2: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    worker2: Processing triggers for man-db (2.7.5-1) ...
    worker2: Setting up libassuan0:amd64 (2.4.2-2) ...
    worker2: Setting up pinentry-curses (0.9.7-3) ...
    worker2: Setting up libnpth0:amd64 (1.2-3) ...
    worker2: Setting up gnupg-agent (2.1.11-6ubuntu2.1) ...
    worker2: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    worker2: Get:1 https://download.docker.com/linux/ubuntu xenial InRelease [66.2 kB]
    worker2: Get:2 https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages [21.0 kB]
    worker2: Hit:3 http://security.ubuntu.com/ubuntu xenial-security InRelease
    worker2: Hit:4 http://archive.ubuntu.com/ubuntu xenial InRelease
    worker2: Hit:5 http://archive.ubuntu.com/ubuntu xenial-updates InRelease
    worker2: Hit:6 http://archive.ubuntu.com/ubuntu xenial-backports InRelease
    worker2: Hit:7 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security InRelease
    worker2: Hit:8 https://esm.ubuntu.com/infra/ubuntu xenial-infra-updates InRelease
    worker2: Fetched 87.2 kB in 2s (31.5 kB/s)
    worker2: Reading package lists...
    worker2: Reading package lists...
    worker2: Building dependency tree...
    worker2: Reading state information...
    worker2: The following additional packages will be installed:
    worker2:   docker-ce-rootless-extras docker-scan-plugin libltdl7 pigz
    worker2: Suggested packages:
    worker2:   aufs-tools cgroupfs-mount | cgroup-lite
    worker2: Recommended packages:
    worker2:   slirp4netns
    worker2: The following NEW packages will be installed:
    worker2:   containerd.io docker-ce docker-ce-cli docker-ce-rootless-extras
    worker2:   docker-scan-plugin libltdl7 pigz
    worker2: 0 upgraded, 7 newly installed, 0 to remove and 0 not upgraded.
    worker2: Need to get 107 MB of archives.
    worker2: After this operation, 466 MB of additional disk space will be used.
    worker2: Get:1 https://download.docker.com/linux/ubuntu xenial/stable amd64 containerd.io amd64 1.4.6-1 [28.0 MB]
    worker2: Get:2 http://archive.ubuntu.com/ubuntu xenial/universe amd64 pigz amd64 2.3.1-2 [61.1 kB]
    worker2: Get:3 http://archive.ubuntu.com/ubuntu xenial/main amd64 libltdl7 amd64 2.4.6-0.1 [38.3 kB]
    worker2: Get:4 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-ce-cli amd64 5:20.10.7~3-0~ubuntu-xenial [41.1 MB]
    worker2: Get:5 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-ce amd64 5:20.10.7~3-0~ubuntu-xenial [24.8 MB]    worker2: Get:6 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-ce-rootless-extras amd64 5:20.10.7~3-0~ubuntu-xenial [9,052 kB]
    worker2: Get:7 https://download.docker.com/linux/ubuntu xenial/stable amd64 docker-scan-plugin amd64 0.8.0~ubuntu-xenial [3,889 kB]
    worker2: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    worker2: Fetched 107 MB in 9s (11.3 MB/s)
    worker2: Selecting previously unselected package pigz.
(Reading database ... 54463 files and directories currently installed.)
    worker2: Preparing to unpack .../pigz_2.3.1-2_amd64.deb ...
    worker2: Unpacking pigz (2.3.1-2) ...
    worker2: Selecting previously unselected package containerd.io.
    worker2: Preparing to unpack .../containerd.io_1.4.6-1_amd64.deb ...
    worker2: Unpacking containerd.io (1.4.6-1) ...
    worker2: Selecting previously unselected package docker-ce-cli.
    worker2: Preparing to unpack .../docker-ce-cli_5%3a20.10.7~3-0~ubuntu-xenial_amd64.deb ...
    worker2: Unpacking docker-ce-cli (5:20.10.7~3-0~ubuntu-xenial) ...
    worker2: Selecting previously unselected package docker-ce.
    worker2: Preparing to unpack .../docker-ce_5%3a20.10.7~3-0~ubuntu-xenial_amd64.deb ...
    worker2: Unpacking docker-ce (5:20.10.7~3-0~ubuntu-xenial) ...
    worker2: Selecting previously unselected package docker-ce-rootless-extras.
    worker2: Preparing to unpack .../docker-ce-rootless-extras_5%3a20.10.7~3-0~ubuntu-xenial_amd64.deb ...
    worker2: Unpacking docker-ce-rootless-extras (5:20.10.7~3-0~ubuntu-xenial) ...
    worker2: Selecting previously unselected package docker-scan-plugin.
    worker2: Preparing to unpack .../docker-scan-plugin_0.8.0~ubuntu-xenial_amd64.deb ...
    worker2: Unpacking docker-scan-plugin (0.8.0~ubuntu-xenial) ...
    worker2: Selecting previously unselected package libltdl7:amd64.
    worker2: Preparing to unpack .../libltdl7_2.4.6-0.1_amd64.deb ...
    worker2: Unpacking libltdl7:amd64 (2.4.6-0.1) ...
    worker2: Processing triggers for man-db (2.7.5-1) ...
    worker2: Processing triggers for ureadahead (0.100.0-19.1) ...
    worker2: Processing triggers for systemd (229-4ubuntu21.31) ...
    worker2: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    worker2: Setting up pigz (2.3.1-2) ...
    worker2: Setting up containerd.io (1.4.6-1) ...
    worker2: Setting up docker-ce-cli (5:20.10.7~3-0~ubuntu-xenial) ...
    worker2: Setting up docker-ce (5:20.10.7~3-0~ubuntu-xenial) ...
    worker2: Setting up docker-ce-rootless-extras (5:20.10.7~3-0~ubuntu-xenial) ...
    worker2: Setting up docker-scan-plugin (0.8.0~ubuntu-xenial) ...
    worker2: Setting up libltdl7:amd64 (2.4.6-0.1) ...
    worker2: Processing triggers for ureadahead (0.100.0-19.1) ...
    worker2: Processing triggers for systemd (229-4ubuntu21.31) ...
    worker2: Processing triggers for libc-bin (2.23-0ubuntu11.3) ...
    worker2: Synchronizing state of docker.service with SysV init with /lib/systemd/systemd-sysv-install...
    worker2: Executing /lib/systemd/systemd-sysv-install enable docker
    worker2: docker-ce set on hold.
==> worker2: Running provisioner: shell...
    worker2: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-85dfgi.sh
    worker2: Reading package lists...
    worker2: Building dependency tree...
    worker2: Reading state information...
    worker2: apt-transport-https is already the newest version (1.2.35).
    worker2: curl is already the newest version (7.47.0-1ubuntu2.19).
    worker2: 0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
    worker2: deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main
    worker2: Hit:1 https://download.docker.com/linux/ubuntu xenial InRelease
    worker2: Hit:2 http://security.ubuntu.com/ubuntu xenial-security InRelease
    worker2: Hit:3 http://archive.ubuntu.com/ubuntu xenial InRelease
    worker2: Get:4 https://apt.kubernetes.io kubernetes-xenial InRelease [154 B]
    worker2: Hit:5 http://archive.ubuntu.com/ubuntu xenial-updates InRelease
    worker2: Hit:6 https://esm.ubuntu.com/infra/ubuntu xenial-infra-security InRelease
    worker2: Get:7 https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages [48.5 kB]
    worker2: Hit:8 http://archive.ubuntu.com/ubuntu xenial-backports InRelease
    worker2: Hit:9 https://esm.ubuntu.com/infra/ubuntu xenial-infra-updates InRelease
    worker2: Fetched 57.9 kB in 1s (34.6 kB/s)
    worker2: Reading package lists...
    worker2: Reading package lists...
    worker2: Building dependency tree...
    worker2: Reading state information...
    worker2: The following additional packages will be installed:
    worker2:   conntrack cri-tools ebtables kubernetes-cni socat
    worker2: The following NEW packages will be installed:
    worker2:   conntrack cri-tools ebtables kubeadm kubectl kubelet kubernetes-cni socat
    worker2: 0 upgraded, 8 newly installed, 0 to remove and 0 not upgraded.
    worker2: Need to get 70.5 MB of archives.
    worker2: After this operation, 309 MB of additional disk space will be used.
    worker2: Get:1 https://apt.kubernetes.io kubernetes-xenial/main amd64 cri-tools amd64 1.13.0-01 [8,775 kB]
    worker2: Get:2 http://archive.ubuntu.com/ubuntu xenial/main amd64 conntrack amd64 1:1.4.3-3 [27.3 kB]
    worker2: Get:3 https://apt.kubernetes.io kubernetes-xenial/main amd64 kubernetes-cni amd64 0.8.7-00 [25.0 MB]
    worker2: Get:4 http://archive.ubuntu.com/ubuntu xenial-updates/main amd64 ebtables amd64 2.0.10.4-3.4ubuntu2.16.04.2 [79.9 kB]
    worker2: Get:5 http://archive.ubuntu.com/ubuntu xenial/universe amd64 socat amd64 1.7.3.1-1 [321 kB]
    worker2: Get:6 https://apt.kubernetes.io kubernetes-xenial/main amd64 kubelet amd64 1.21.2-00 [18.8 MB]
    worker2: Get:7 https://apt.kubernetes.io kubernetes-xenial/main amd64 kubectl amd64 1.21.2-00 [8,966 kB]
    worker2: Get:8 https://apt.kubernetes.io kubernetes-xenial/main amd64 kubeadm amd64 1.21.2-00 [8,547 kB]
    worker2: dpkg-preconfigure: unable to re-open stdin: No such file or directory
    worker2: Fetched 70.5 MB in 8s (8,320 kB/s)
    worker2: Selecting previously unselected package conntrack.
(Reading database ... 54715 files and directories currently installed.)
    worker2: Preparing to unpack .../conntrack_1%3a1.4.3-3_amd64.deb ...
    worker2: Unpacking conntrack (1:1.4.3-3) ...
    worker2: Selecting previously unselected package cri-tools.
    worker2: Preparing to unpack .../cri-tools_1.13.0-01_amd64.deb ...
    worker2: Unpacking cri-tools (1.13.0-01) ...
    worker2: Selecting previously unselected package ebtables.
    worker2: Preparing to unpack .../ebtables_2.0.10.4-3.4ubuntu2.16.04.2_amd64.deb ...
    worker2: Unpacking ebtables (2.0.10.4-3.4ubuntu2.16.04.2) ...
    worker2: Selecting previously unselected package kubernetes-cni.
    worker2: Preparing to unpack .../kubernetes-cni_0.8.7-00_amd64.deb ...
    worker2: Unpacking kubernetes-cni (0.8.7-00) ...
    worker2: Selecting previously unselected package socat.
    worker2: Preparing to unpack .../socat_1.7.3.1-1_amd64.deb ...
    worker2: Unpacking socat (1.7.3.1-1) ...
    worker2: Selecting previously unselected package kubelet.
    worker2: Preparing to unpack .../kubelet_1.21.2-00_amd64.deb ...
    worker2: Unpacking kubelet (1.21.2-00) ...
    worker2: Selecting previously unselected package kubectl.
    worker2: Preparing to unpack .../kubectl_1.21.2-00_amd64.deb ...
    worker2: Unpacking kubectl (1.21.2-00) ...
    worker2: Selecting previously unselected package kubeadm.
    worker2: Preparing to unpack .../kubeadm_1.21.2-00_amd64.deb ...
    worker2: Unpacking kubeadm (1.21.2-00) ...
    worker2: Processing triggers for man-db (2.7.5-1) ...
    worker2: Processing triggers for ureadahead (0.100.0-19.1) ...
    worker2: Processing triggers for systemd (229-4ubuntu21.31) ...
    worker2: Setting up conntrack (1:1.4.3-3) ...
    worker2: Setting up cri-tools (1.13.0-01) ...
    worker2: Setting up ebtables (2.0.10.4-3.4ubuntu2.16.04.2) ...
    worker2: update-rc.d: warning: start and stop actions are no longer supported; falling back to defaults
    worker2: Setting up kubernetes-cni (0.8.7-00) ...
    worker2: Setting up socat (1.7.3.1-1) ...
    worker2: Setting up kubelet (1.21.2-00) ...
    worker2: Setting up kubectl (1.21.2-00) ...
    worker2: Setting up kubeadm (1.21.2-00) ...
    worker2: Processing triggers for ureadahead (0.100.0-19.1) ...
    worker2: Processing triggers for systemd (229-4ubuntu21.31) ...
    worker2: kubelet set on hold.
    worker2: kubeadm set on hold.
    worker2: kubectl set on hold.
==> worker2: Running provisioner: shell...
    worker2: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-1twt5g6.sh
==> worker2: Running provisioner: shell...
    worker2: Running: C:/Users/ADMINI~1/AppData/Local/Temp/vagrant-shell20210811-4260-yaikmg.sh
    worker2: [preflight] Running pre-flight checks
    worker2:    [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
    worker2: [preflight] Reading configuration from the cluster...
    worker2: [preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
    worker2: [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    worker2: [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    worker2: [kubelet-start] Starting the kubelet
    worker2: [kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...
    worker2:
    worker2: This node has joined the cluster:
    worker2: * Certificate signing request was sent to apiserver and a response was received.
    worker2: * The Kubelet was informed of the new secure connection details.
    worker2:
    worker2: Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
    worker2:
    worker2: Environment='KUBELET_EXTRA_ARGS=--node-ip=192.128.0.202'
PS >
```
