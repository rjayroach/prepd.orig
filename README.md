# Prepd-project

Prepd-project is a set of Terraform Plans and Ansible Playbooks to manage Infrastructure and Project Deployments

## Clone Existing Project
- git clone the existing project
- copy product credentials to the project_root (see below)

## Create a New Project

### New Client

- Create a new GH Company
- Create an AWS Account and two IAM Groups: Administrators and ReadOnlyAdministrators
- Create the project in prepd

```ruby
c = Client.create(name: 'c2p4')
```

### New Project
- create a GH repo for the project
- create an IAM user for project_name-terraform and download the AWS credentials CSV
- create an IAM user for project_name-ansible and download the AWS credentials CSV
- use prepd to create the project using the repo_url and path names (tf_creds and ansible_creds) to CSV files

```ruby
c = Client.find_by(name: 'c2p4')
c.projects.new(name: 'legos', repo_url: 'git@github.com:my_git_hub_account/legos.git')
c.tf_creds = 'Users/dude/aws/legos-terraform.csv'
c.ansible_creds = 'Users/dude/aws/legos-ansible.csv'
c.save
```


## Notes

### Project Credentials
Prepd will create the following credential (hidden) files in project_root:

.boto: AWS IAM credentials that give read only access to Ansible
.developer.yml: Developer’s git account (and other account) details
.terraform-vars.txt: AWS IAM credentials that give full access to CRUD AWS resources
.vault-password.txt: a UUID used to encrypt and decrypt ansible vault files
.id_rsa.pub: the public key uploaded to AWS as the primary key pair for accessing EC2 instances
.id_rsa: the private key

When cloning this project to a new machine these files will need to be manually copied to the new machine as they are not stored in the repository

If giving a developer access to the machine (but not terraform or ansible) then add their public key to the instance’s ~/.ssh/authorized_keys
The developer uses ssh-agent forwarding to access the machine from the VM

- either prepd creates the creates these files or a human will copy them
- terraform will use project_root/id_rsa.pub to upload key_material to AWS for the machine key
- dev.yml will check if the project_root and: 1) if .boto exists link it, 2) if id_rsa and id_rsa.pub exist then link them
- the developer can then do ssh-add which will auto load ~/.ssh/id_rsa to login or run ansible

### NOTEs on EC2 Key Pair:
- Terraform does not create key pairs and can only upload an existing key pair
- key pairs in AWS are stored by region so it makes sense to generate a key pair on the localhost and upload the key_material to AWS as necessary per region
- Terraform is the single tool to manage infrastructure so it must upload the key pair
- Ansible is the single tool to configure instances so it needs the key pair in order to access and configure them
- only prepd or manual transfer is what creates and/or gives access to credentials
- credentials are *never* stored in a repo including in an encrypted vault


## Using
- Initialize the VM: run vagrant up; this will run dev.yml to setup the machine for development
TODO: (for dev.yml)
- if project-root/.boto exists then link it to ~/.boto and download ec2.py and ec2.ini and chmod ec2.py


## Description

### Infrastructure

Terraform plan manages all the AWS infrastructure

### Configuration
which when combined with these
[Ansible roles](https://github.com/rjayroach/ansible-roles/) provides a set of infrastructure blueprints
for development, staging and production in which to deploy a project with one or more applications

The blueprints provide a stand-alone provisioning system based on Ansible, however
when they are managed with the Prepd gem, project and application setup becomes fully automated.

Regardless of whether Prepd is used to manage the blueprints, Ansible playbooks are the primary tool used to
provision the infrastructure across four specific environments: local, devleopment, staging and production


### Default infrastructure

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

## Variables

### Locations

Variables are stored in either of two locations:
- a sub-directory of the inventory/group_vars directory
- a sub-directory of the inventory/host_vars directory

The sub-directory matches either the name of the environment, e.g. local, development, staging or production
or it matches the name of a role, e.g. dev

Variables are stored in either plain text files (vars.yml) or encrypted files (vault)

Examples:
- vars that apply to the local environment are located in `inventory/group_vars/local/vars.yml`
- encrypted vars that apply to all environemnts are located in `inventory/group_vars/all/vault`
- vars that apply to dev (local and development) are set in `inventory/group_vars/dev/vars.yml`

Source code repositories and other dev related info is stored inventory/group_vars/dev/vars.yml

### Encrypted Variables

When creating a new project, prepd generates a uuid to be used as a secret passphrase for encyrypting vault files.
This passphrase is located in project_root/.vault_pass.txt which is listed in .gitignore so it is not committed to the repository.
Use the [ansible-vault](http://docs.ansible.com/ansible/playbooks_vault.html) command to edit an encrypted file, e.g.:

```bash
cd ansible
ansible-vault edit inventory/group_vars/all/vault
```

### Variables in Playbooks
Application variables, both plain text and encrypted, are merged together into a single dictionary hash name `app_vars`.
Each application has a key under `app_vars` defined in the app-vars.yml file.
The template generated by prepd contains keys for two applications: 'cool_app_1' and 'cool_app_2'.
If there is only one application then remove references to 'cool_app_2' and change the name 'cool_app_1'
to the application name.
This needs to be done in each of the inventory/group_vars/environment/vars.yml and vault files.


## Using

### Connect to local machine

```bash
vagrant up
vagrant ssh node0 OR ssh -4 -A vagrant@node0.{project_name}.local
cd {project_name}/ansible
./dev.yml # run the role configuration manually (this is automatically run when the machine is first created by Ansible)
```

### Database Backup and Restore

```bash
cd ansible
./db-utils --limit node0.staging --tags dump,fetch
./db-utils --limit node0.local --tags restore
```
