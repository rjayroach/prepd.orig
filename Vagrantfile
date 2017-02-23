# TODO: prepd is a directory in prepd-project that can be invoked with cli as well

def invoke_prepd?
  ARGV[0].eql?('up') and File.exist?('prepd.rb') and not Dir.exist?('ansible/roles')
end

if invoke_prepd?
  require_relative 'prepd'
  project = Prepd::Project.new
  project.create
end

Vagrant.configure(2) do |config|
  host_name = Dir.pwd.split('/').pop(2).reverse.join('.')
  project_name = 'prepd'
  config.vm.box = 'debian/contrib-jessie64'
  config.vm.box_check_update = false
  config.vm.provision :shell do |shell|
    ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
    shell.inline = <<-SHELL
      echo '' >> /home/vagrant/.ssh/authorized_keys
      echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
    SHELL
  end
  config.vm.provision :shell, path: 'bootstrap.sh'
  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |v|
    v.memory = 2048
    v.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000 ]
  end

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false

  (0..3).each do |i|
    master = autostart = forward_ports = i.eql?(0)
    config.vm.define "node#{i}", autostart: autostart do |node|
      node.vm.provider :virtualbox do |v|
        v.name = "node#{i}.#{host_name}.local"
      end

      node.vm.synced_folder '.', '/vagrant', disabled: true
      node.vm.synced_folder '.', "/home/vagrant/#{project_name}"

      # Networking
      node.vm.hostname = "node#{i}.#{host_name}.local"
      node.vm.network 'private_network', type: :dhcp
      node.hostmanager.aliases = ["node#{i}.local"]
      node.hostmanager.ip_resolver = proc do |vm, resolving_vm|
        if hostname = (vm.ssh_info && vm.ssh_info[:host])
          `vagrant ssh node#{i} -c "/sbin/ifconfig eth1" | grep "inet addr" | tail -n 1 | egrep -o "[0-9\.]+" | head -n 1 2>&1`.split("\n").first[/(\d+\.\d+\.\d+\.\d+)/, 1]
        end
      end

      # Port Forwarding
      if forward_ports
        node.vm.network 'forwarded_port', guest: 2375, host: 2375, auto_correct: true    # docker
        node.vm.network 'forwarded_port', guest: 2376, host: 2376, auto_correct: true    # docker
        node.vm.network 'forwarded_port', guest: 3000, host: 3000, auto_correct: true    # rails
        node.vm.network 'forwarded_port', guest: 4200, host: 4200, auto_correct: true    # ember
        node.vm.network 'forwarded_port', guest: 7357, host: 7357, auto_correct: true    #
        # node.vm.network 'forwarded_port', guest: 35729, host: 35729, auto_correct: true  # reload
        node.vm.network 'forwarded_port', guest: 49152, host: 49152, auto_correct: true  # live-reload
      end

      # Configuration
      node.vm.provision :ansible_local do |ansible|
        ansible.install = false
        ansible.playbook = master ? 'config-master.yml' : 'config-cluster.yml'
        ansible.provisioning_path = "/home/vagrant/#{project_name}/ansible"
        ansible.inventory_path = 'inventory/local'
        ansible.limit = "node#{i}.local"
      end
    end
  end

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
  end
end
