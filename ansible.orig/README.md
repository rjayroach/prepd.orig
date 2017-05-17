# Using

## Envrionments

There are four: development, local, staging and production

Local is based on VirtualBox VMs managed with Vagrant and are 1 master node and 3 nodes for the cluster
The other environments are expected to be in the cloud.

Machines are configured in each environment using one or both of these playbooks:

- config-master.yml: Sets up the master node in the environment, .e.g developer tools in 'local' and 'developement' envs
- config-cluster.yml: Sets up the cluster in the specific environment

Specify the environment against which the playbook is run by specifying the -i switch when invoking the playbook
The default environment is 'local'


### Variables

group_vars/environment/vars.yml

- cluster_type: none, docker, docker-swarm, kubernetes
- master: developer, developer_and_provisioner

These variables determine what type of cluster is setup when you run config-cluster.yml

## Roles

There are roles for the cluster: etcd, master and node


## Application Groups

Application Groups are defined in Ansible Playbooks. The following files comprise a Group:

### In ~/prepd/ansible/application-name:

- application.yml: values that define git repos, rails, ember, etc, db and ENV vars for setting up on a developer machine
- container.yml: similar to a docker-compose.yml that defines the container and dependent containers
- docker.yml: tasks that launch the application as a docker container (on a host or docker swarm)
- kubernetes.yml: tasks that launch the application into a kubernetes cluster

### In ~/group_vars/all/application-name:

### In ~/prepd/ansible:

- application-name-cluster.yml: includes the
- application-name-master.yml

In the Developer IE, add the following files in ~/project_name/ansible:

- Create the application installation settings


### Setup Application for Development

file: config-master.yml

This playbook:
- installs the application source code, service dependencies and configures db, envs, etc on local machine
- pulls the application sources from a repository
- initializes the application(s)


1. Configure Application Vars
- group_vars/all/project-name.yml: these are ENV values for the application

2. Configure application
- application-name/application.yml:
- install language tools, e.g. Ruby, Node, etc
- pull down the git project(s)
- run bundle and migrations
- run any other project config stuff, e.g. tmuxinator link files, etc.


## Notes on Ansible Roles

1. common
- install packages common across all servers, e.g. tcpdump, tmux
- place configuration files common across all servers, e.g. ~/.inputrc, ~/.tmux.conf

2. dev-tools
- install packages needed for the development machines

3. developer
- configure developer specific settings, e.g. git and docker credentials
