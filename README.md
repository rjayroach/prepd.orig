## Overview

Provides:
- a 'master' machine for development, testing, building images, load balancing and managing a docker swarm cluster
- a 3 node infrastructure to emulate production

### Default infrastructure

Default Infrastructure provides a 3 node cluster with basic serivces that emulate cloud (AWS) resources
All services are implemented as docker containers
Can be updated in run/docker-compose.yml

- master: Consul Server, Registrator, Nginx (ELB)
- node1: Consul, Registrator, Postgresql (RDS)
- node2: Consul, Registrator, Redis (Elasticache)
- node3: Consul, Registrator, DynamoDB

### Services

TODO: List consul DNS names where the above services are reachable

### Project Infrastructure

Project is defined in run/docker-compose.override.yml See [docker](https://docs.docker.com/compose/extends/)
- Rails container exposing HTTP via Puma (default)
- Rails container override CMD to run Resque
- Rails container override CMD to run Scheduler
- Ember app


## Requirements

- VirtualBox
- Vagrant
- Vagrant plugins

```bash
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-cachier
```

## Nodes

### Dev
- Has a fixed IP on the same network as the swarm cluster
- Is the swarm master

### Swarm Cluster


## Using

```bash
git clone git@github.com:rjayroach/prepd.git
cd prepd/files/ansible
git submodule add git@github.com:rjayroach/ansible-roles roles
```

- Add your secret passphrase to .vault_pass.txt
- Encrypt ansible/secrets.yml

```bash
ansible-vault encrypt secrets/recheck/env --vault-password-file .vault_pass.txt
```

```bash
vagrant up
```

## Examples

### Ansible roles

This project includes ansible roles which are accessible from the VM at /vagrant/ansible/roles

The roles can be edited and tested from the host or directly inside the VM

#### Host

```bash
cd rose-host/ansible
ansible-playbook provision.yml
```

```bash
cd /home/vagrant/ansible
ansible-playbook provision.yml
```

### Docker

```bash
docker images
```
