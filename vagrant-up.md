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
