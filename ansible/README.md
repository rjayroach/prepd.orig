
## Configuring Project Applications

in ~/<project_name>/ansible

### Application Installation

#### Application Configuration

file: vars/app-dev.yml

#### Services and source code

file: app-dev.yml

# NOTE: This playbook:
#   - installs the application's service dependencies on local machine
#   - pulls the application sources from a repository
#   - initializes the application(s)

#### Application Templates

file: templates/*

### Application Variables

#### Global for application

file: vars/app-vars.yml

#### Environment Specific - local

file: inventory/group_vars/local/vars.yml
```yaml
group_vars:
  platform:
    domain: getperx.local
    envs:
      DATABASE_HOST: localhost
      DATABASE_NAME: localhost
      RABBITMQ_HOST: localhost
      REDIS_HOST: localhost
  retail:
    domain: getperx.local
    envs:
      DATABASE_HOST: localhost
```

#### Environment Specific - local (encrypted)

file: inventory/group_vars/local/vault



## Getting docker running with Ansible

1. build the base image as a separate project
2. build folr5 as a docker image using ansible

Questions:
- using a single Dockerfile for multiple projects
- need to get the env file setup for the proper environment and specify in folr/docker-compose.yml
- this should get the correct env file for the environment



## Setup

1. Copy ../developer.yml.example to ../developer.yml and edit with your credentials
2. Create ../vault-password.txt

## Notes on Roles

1. common
- install packages common across all servers, e.g. tcpdump, tmux
- place configuration files common across all servers, e.g. ~/.inputrc, ~/.tmux.conf

2. dev-tools
- install packages needed for the development machines

3. developer
- configure developer specific settings, e.g. git and docker credentials

## Project Setup

1. Configure Project Vars
- project-vars.yml: project vars for GH; use Redis, yes, no

### Development Environment

Provision Infrastructure on VMs on Laptop

1. Instantiate VirtualBox Hosts
- local-machines.yml (formally provision.yml) - brings up the VM hosts and installs basic packages
- install ansible
- install docker

2. Bring up a docker swarm cluster 
- swarm-cluster.yml: requires ansible to get the IP address

3. Provision Infrastructure
- TODO: local-services.yml: installs the project's supporting services, e.g. Postgres and Redis, directly onto the VMs and configures root pwd, etc

OR
- swarm-services.yml: install the project's supporting services defined in docker-compose-services.yml into the cluster and configures root pwd, etc
- docker-compose-services.yml: defines the project's supporting services, e.g. Postgres and Redis


### Production Cloud Install (TODO)

Provision Infrastructure on AWS

1. Instantiate EC2 Hosts and Other AWS Infra, e.g. RDS, Elasticache
- Terraform: Provision and configure the project's serivces in the cloud; configure root pwd, etc

2. Bring up a docker swarm cluster 
- swarm-cluster.yml: installs a docker cluster onto the EC2s


## Project Lifecycle

### Development

1. Configure Project Services
- project-services.yml: Whether local or cloud, create the project's databases, configure redis, rabbitmq, etc

2. Setup Project Master
- project.yml:
- install language tools, e.g. Ruby, Node, etc
- pull down the git project(s)
- run bundle and migrations
- run any other project config stuff, e.g. tmuxinator link files, etc.


### Testing

1. docker-compose.yml 
- deploys all the application services into the cluter

2. docker-compose-test.yml
- overrides each application container's command to run Rspec tests rather than the ususal web server

3. CI Server (?)

### Production



## Master

# See: [https://docs.docker.com/swarm/install-manual/#/step-6-communicate-with-the-swarm]

Setup Consul and Swarm Manager on Master

```bash
docker run -d -p 8500:8500 --net=host --name=consul progrium/consul --bind 10.100.199.200 -server -bootstrap
docker run -d -p 4000:4000 swarm manage -H :4000 --replication --advertise 10.100.199.200:4000 consul://10.100.199.200:8500
```

Setup Swarm Manager on Node1

```bash
node1 'docker run -d -p 4000:4000 swarm manage -H :4000 --replication --advertise 10.100.199.201:4000 consul://10.100.199.200:8500'
```

Setup Swarm Nodes on Nodes 2 & 3

```bash
node2 'docker run -d swarm join --advertise=10.100.199.202:2375 consul://10.100.199.200:8500'
node2 'docker run -d --name=registrator --net=host --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest -ip 10.100.199:202 consul://10.100.199.200:8500'
node3 'docker run -d swarm join --advertise=10.100.199.203:2375 consul://10.100.199.200:8500'
node3 'docker run -d --name=registrator --net=host --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest -ip 10.100.199:203 consul://10.100.199.200:8500'
```

Run Redis on Cluster

```bash
docker -H :4000 run --name some-redis -d redis                                                                                                                                                                            [ruby-2.1.5p273]
```
