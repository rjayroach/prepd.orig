Vagrant.configure(2) do |config|
  # Uncomment for test mode
  # test_mode = true
  # testing_dir = '/Users/rjayroach/projects/rjayroach'
  project_name = Dir.pwd.split('/').last(2).join('-')
  config.vm.box = 'debian/contrib-jessie64'
  config.vm.box_check_update = false
  config.vm.provision :shell do |shell|
    ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
    shell.inline = <<-SHELL
      echo '' >> /home/vagrant/.ssh/authorized_keys
      echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      mkdir -p /home/vagrant#{project_name}
    SHELL
  end
  config.vm.provision :shell, path: 'bootstrap.sh'
  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |v|
    v.memory = 2048
  end

  config.vm.define :master, primary: true do |master|
    master.vm.synced_folder '.', '/vagrant', disabled: true
    # Mounts
    if defined?(test_mode)
      master.vm.synced_folder "#{testing_dir}/prepd/files", "/home/vagrant/#{project_name}"
      master.vm.synced_folder "#{testing_dir}/ansible-roles", "/home/vagrant/#{project_name}/ansible/roles"
    else
      master.vm.synced_folder '.', "/home/vagrant/#{project_name}"
    end
    # End mounts
    master.vm.hostname = "#{project_name}-master"
    master.vm.network 'private_network', ip: '10.100.199.200'
    master.vm.network 'forwarded_port', guest: 2376, host: 2376
    master.vm.network 'forwarded_port', guest: 2375, host: 2375
    master.vm.network 'forwarded_port', guest: 3000, host: 3000
    master.vm.network 'forwarded_port', guest: 4200, host: 4200
    master.vm.network 'forwarded_port', guest: 7357, host: 7357
    master.vm.network 'forwarded_port', guest: 35729, host: 35729
    master.vm.provision :ansible_local do |ansible|
      ansible.install = false
      ansible.playbook = 'dev.yml'
      ansible.provisioning_path = "/home/vagrant/#{project_name}/ansible/base"
      ansible.inventory_path = 'inventory'
    end
  end

  (1..3).each do |i|
    config.vm.define "node#{i}", autostart: false do |node|
      node.vm.synced_folder '.', '/vagrant', disabled: true
      # Mounts
      if defined?(test_mode)
        node.vm.synced_folder "#{testing_dir}/prepd/files", "/home/vagrant/#{project_name}"
        node.vm.synced_folder "#{testing_dir}/ansible-roles", "/home/vagrant/#{project_name}/ansible/roles"
      else
        node.vm.synced_folder '.', "/home/vagrant/#{project_name}"
      end
      node.vm.hostname = "#{project_name}-node#{i}"
      node.vm.network 'private_network', ip: "10.100.199.20#{i}"
      node.vm.provision :ansible_local do |ansible|
        ansible.install = false
        ansible.playbook = 'cluster.yml'
        ansible.provisioning_path = "/home/vagrant/#{project_name}/ansible/base"
        ansible.inventory_path = 'inventory'
        ansible.limit = "node#{i}.local"
      end
    end
  end

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
  end
end
