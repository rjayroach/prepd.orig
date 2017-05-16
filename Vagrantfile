ssh_intf = 'eth1'

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
    v.customize ['guestproperty', 'set', :id, '/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold', 10000 ]
    v.customize ['modifyvm', :id, '--nictype1', 'virtio']
  end

  if Vagrant.has_plugin?('vagrant-hostmanager')
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
  end

  (0..3).each do |i|
    autostart = forward_ports = i.eql?(0)
    config.vm.define "node#{i}", autostart: autostart do |node|
      node.vm.provider :virtualbox do |v|
        v.name = "node#{i}.#{host_name}.local"
      end

      node.vm.synced_folder '.', '/vagrant', disabled: true
      node.vm.synced_folder '.', "/home/vagrant/#{project_name}"

      # Networking
      node.vm.hostname = "node#{i}.#{host_name}.local"
      node.vm.network 'private_network', type: :dhcp, nic_type: 'virtio'

      if Vagrant.has_plugin?('vagrant-hostmanager')
        node.hostmanager.aliases = ["node#{i}.local"]
        node.hostmanager.ip_resolver = proc do |vm, resolving_vm|
          if hostname = (vm.ssh_info && vm.ssh_info[:host])
            `vagrant ssh node#{i} -c "/sbin/ifconfig #{ssh_intf}" | grep "inet addr" | tail -n 1 | egrep -o "[0-9\.]+" | head -n 1 2>&1`.split("\n").first[/(\d+\.\d+\.\d+\.\d+)/, 1]
          end
        end
      end

      # Port Forwarding
      [
        2375,  # docker
        2376,  # docker
        3000,  # rails
        4200,  # ember
        7357,
        # 35729, # reload
        49152  # livereload
      ].each do |p|
        node.vm.network 'forwarded_port', guest: p, host: p, auto_correct: true
      end if forward_ports
    end
  end

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
  end
end
