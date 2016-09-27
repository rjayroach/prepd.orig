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

### Secrets
prepd will generate a uuid as a secret passphrase to .vault_pass.txt
ansible.cfg will use the passphrase when dealing with encrypted data
encrypted files are created per environment in a file named vault
use ansible-vault to edit an encrypted file, e.g.:

```bash
cd ansible
ansible-vault edit inventory/group_vars/all/vault
```

### Connect to local machine

```bash
vagrant up
vagrant ssh node0 or ssh -A node0.{project_name}.local
cd {project_name}/ansible
run the role configuration, e.g ./dev.yml
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
