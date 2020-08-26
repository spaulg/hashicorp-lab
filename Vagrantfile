Vagrant.configure(2) do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 6000
    vb.cpus = 4

    vb.customize [ "modifyvm", :id, "--uartmode1", "file", File::NULL ]
  end

  # Server
  config.vm.define "server1", autostart: false do |node|
    node.vm.box = "ubuntu/focal64"

    node.vm.hostname = "server1"
    node.hostmanager.aliases = %w(server1.test)

    node.vm.network "private_network", ip: "172.20.20.110"
    node.vm.provision "shell", path: "server-provisioner.sh"
  end

  # Client 1
  config.vm.define "client1", autostart: false do |node|
    node.vm.box = "ubuntu/focal64"

    node.vm.hostname = "client1"
    node.hostmanager.aliases = %w(client1.test)

    node.vm.network "private_network", ip: "172.20.20.120"
    node.vm.provision "shell", path: "client-provisioner.sh"
  end

  # Client 2
  config.vm.define "client2", autostart: false do |node|
    node.vm.box = "ubuntu/focal64"

    node.vm.hostname = "client2"
    node.hostmanager.aliases = %w(client2.test)

    node.vm.network "private_network", ip: "172.20.20.130"
    node.vm.provision "shell", path: "client-provisioner.sh"
  end
end
