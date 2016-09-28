# Prepd-project

Prepd-project is a set of Ansible playbooks which when combined with these
[Ansible roles](https://github.com/rjayroach/ansible-roles/) provides a set of infrastructure blueprints
for development, staging and production in which to deploy a project with one or more applications

The blueprints work as a stand-alone provisioning system based on Ansible, however when they are  managed with the Prepd gem
project and application setup becomes fully automated.
Regardless of whether Prepd is invoked or not, Ansible playbooks are the primary tool used to provision the
infrastructure across four specific environments: local, devleopment, staging and production


## Default infrastructure

The Vagrantfile (for local) and the Ansible playbooks (for all other environments) provision a Default Infrastructure
which creates a 3 node cluster with basic serivces

- node0: This is the primary machine for development and management of cluster services
- node1-3: These are cluster nodes

node0 can run without other nodes


## Roles

### Dev

This includes only node0 in the 'dev' role

- node0: a 'master' machine for development, testing, building images, load balancing and managing a docker swarm cluster

### Cluster

This includes node0 in the 'master' role

- node0: Consul Server, Registrator, Nginx (ELB)
- node1: Consul, Registrator, Postgresql (RDS)
- node2: Consul, Registrator, Redis (Elasticache)
- node3: Consul, Registrator, DynamoDB

## Environments

### Local and Development

Local (vagrant) and Development (AWS) have common functionality in that they can both implement either 'dev' or 'dev' and 'cluster' roles
When just using the 'dev' role then it is a single machine with the applications and the supporting services, e.g. PG, Redis, etc.

However, when the 'cluster' role is applied a docker swarm network is created to emulate a cluster running on cloud (AWS) resources in production


### Staging and Production

This assumes that supporting services may be installed using AWS (RDS, Elasticache, etc) or as services installed directly on EC2s or as docker
containers


## Supporting Services

Can be updated in run/docker-compose.yml
TODO: List consul DNS names where the above services are reachable

### Project Infrastructure

Project is defined in run/docker-compose.override.yml See [docker](https://docs.docker.com/compose/extends/)
- Rails container exposing HTTP via Puma (default)
- Rails container override CMD to run Resque
- Rails container override CMD to run Scheduler
- Ember app


## Installing

```bash
git clone git@github.com:rjayroach/prepd-project.git
cd prepd-project/ansible
git submodule add git@github.com:rjayroach/ansible-roles roles
```

## Using

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
./dev.yml # runs the role configuration
```


## Examples

### Ansible roles

TODO
