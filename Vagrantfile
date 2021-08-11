Vagrant.configure("2") do |config|

  # enable vagrant-env (.env)
  config.env.enable

  # set constants
  IMAGE_NAME = ENV['IMAGE_NAME']
  MEMORY_SIZE_IN_GB = ENV['MEMORY_SIZE_IN_GB'].to_i
  CPU_COUNT = ENV['CPU_COUNT'].to_i
  MASTER_NODE_COUNT = ENV['MASTER_NODE_COUNT'].to_i
  WORKER_NODE_COUNT = ENV['WORKER_NODE_COUNT'].to_i
  MASTER_NODE_IP_START = ENV['MASTER_NODE_IP_START']
  WORKER_NODE_IP_START = ENV['WORKER_NODE_IP_START']

  # 2021-08-11 추가 #########################################
  # 192.168.120.XXX 192.168.232.XXX" -- 차단 대역대
  APISERVER_IP="192.128.0.11"
  K8S_USER="vagrant"
  VAGRANT_ROOT = File.dirname(File.expand_path(__FILE__))
  file_to_disk = File.join(VAGRANT_ROOT, 'filename.vdi')
  CLUSTER_CIDR="10.128.0.0/16"
  POD_CIDR="10.129.0.0/16"
  # SERVICE_CIDR="10.128.0.0/12
  #########################################################

  # set variables
  master_node_ip = ''
  worker_node_ip = ''

  config.vm.box = IMAGE_NAME

  config.vm.provider "virtualbox" do |vb|

    vb.memory = 1024 * MEMORY_SIZE_IN_GB
    vb.cpus = CPU_COUNT

  end

  config.vm.provision "shell", path: "pre.sh"

  config.vm.provision "shell", path: "install-docker.sh"
  config.vm.provision "shell", path: "install-kube-tools.sh"

  config.vm.provision "shell", path: "post.sh"

  (1..MASTER_NODE_COUNT).each do |i|
    config.vm.define "master" do |master|

      master_node_ip = "#{MASTER_NODE_IP_START}#{i}"
      master.vm.network "private_network", ip: "#{master_node_ip}"
      master.vm.hostname = "k8s-master"

      # init master node.
      master.vm.provision "shell", path: "init-master-node.sh", env: {"NODE_IP" => "#{master_node_ip}"}

      # prepare kubectl for vagrant user
      master.vm.provision "shell", privileged: false, path: "prepare-kubectl.sh"

      # prepare kubectl for root user
      master.vm.provision "shell", privileged: true, path: "prepare-kubectl.sh"

      # install cni.
      master.vm.provision "shell", path: "install-cni-calico.sh"

    end
  end

  (1..WORKER_NODE_COUNT).each do |i|
    config.vm.define "worker#{i}" do |node|

      worker_node_ip = "#{WORKER_NODE_IP_START}#{i}"
      node.vm.network "private_network", ip: "#{worker_node_ip}"
      node.vm.hostname = "k8s-worker-#{i}"

      # init slave node.
      node.vm.provision "shell", path: "init-worker-node.sh", env: {"NODE_IP" => "#{worker_node_ip}"}

    end
  end

end