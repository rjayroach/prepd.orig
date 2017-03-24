# Manual Installation of Dependencies

## Ansible

Tested with version 2.2.0

### Install on MacOS

If planning to install on a clean machine:
1. Wipe Mac: http://support.apple.com/kb/PH13871  OR http://support.apple.com/en-us/HT201376
2. Create New User with Admin rights

Install Homebrew:

```bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install python with zlib and ssl support

```bash
xcode-select --install
brew install openssl
brew link openssl --force
brew uninstall python
brew install python --with-brewed-openssl
sudo easy_install pip
sudo pip install -U ansible
sudo pip install -U setuptools cryptography markupsafe
sudo pip install -U ansible boto
```

### Install on Ubuntu

```bash
apt-get install ansible
```

## VirtualBox

Install VirtualBox from [here](https://www.virtualbox.org/wiki/Downloads)

## Vagrant

Install Vagrant from [here](https://www.vagrantup.com/docs/installation/)

```bash
vagrant plugin install vagrant-vbguest      # keep your VirtualBox Guest Additions up to date
vagrant plugin install vagrant-cachier      # caches guest packages
vagrant plugin install vagrant-hostmanager  # updates /etc/hosts file when machines go up/down
```

### vagrant-hostmanager
This plugin automatically updates the host's /etc/hosts file when vagrant machines go up/down

In order to do that it needs sudo password or sudo priviledges.
To avoid being asked for the password every time the hosts file is updated,
[enable passwordless sudo](https://github.com/devopsgroup-io/vagrant-hostmanager#passwordless-sudo)
for the specific command that hostmanager uses to update the hosts file


### SSH configuration

This is not strictly necessary, but it will make it quicker to connect to vagrant machines and not
require you to be in the project directory in order to connect to the VM

	Host *.local
		User vagrant
		ForwardAgent yes
		AddressFamily inet
