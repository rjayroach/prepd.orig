# Prepd-project

This repository creates a Virutal Machine that consists of:

- A development environment based on the latest Debian distribution
- A set of Terraform Plans to provision infrastructure
- A group of Ansible Playbooks to configure the Infrastructure and deploy the relevant projects

# Quick Start

## Clone an Existing Project

- Use git to clone this repository
- Pull the git submodules: `git submodule update --init --recursive`
- Use the prepd gem to [copy product credentials](https://github.com/rjayroach/prepd#transfer-credentials-to-new-machine)
- Boot the Development Environment

```bash
vagrant up
```

OR

## Create a New Project

View the [prepd README.md](https://github.com/rjayroach/prepd)


# Overview

## Projects and Applications

A Project consists of:
- A group of one or more Applications known as an Application Group (AG), and
- One or more Infrastructure Environments (IE), e.g. production, into which the AG is deployed

Each IE has it's own unique definition and is logically or physically separate from the other IEs

IEs and AGs are defined by blueprints


## Prepd Virtual Machine

A Prepd Virtual Machine (PVM) encapsulates a Project by providing:

- blueprints that define the IEs and AGs
- a Development IE
- the cluster-manager for the Local IE

The PVM is used to:

- Spin up IEs
- Deploy AGs into the IEs
- Add new applications to the AG


### Blueprints

The default PVM contains blueprints for creating IEs and to deploy the AG into those IEs

### IE blueprints

A Prepd project has the following environments built in by default: development, local, qa, staging and production
Each environment can be modified to provide unique infrastructure, but already work out of the box. The built in blueprints provide:

#### Development

The Development IE is designed to run on one or more developer machines and can also be easily provisioned and configured to run on AWS EC2.
The developer machine IE is defined in project_root/Vagrantfile and is provisioned when running vagrant up for the first time.
The machine will be automatically configured from the playbook `config-development.yml` the first time the machine is brought up.

- To re-provision the Development IE run `vagrant destroy` followed by `vagrant up` in project_root.
- To re-configure the Development IE run `vagrant provision` OR in the PVM, `cd project_root/ansible && ./config-development.yml`

To run development IE on EC2, do the following:

- run the `tga` command in project_root/terraform/development
- run `config-development.yml` in project_root/ansible

A use case for doing this is to be able to run the application group in a development environment on a publicly accessible machine
for testing with mobile phone clients

#### Local

The Local IE is defined in the same Vagrantfile and provisions a three node Docker Swarm cluster.
The cluster runs consul and registrator containers to manage container discovery

The Local IE is provisioned when running `vagrant up node[1:3]` for the first time.
The nodes will be automatically configured from the playbook `config-local.yml` the first time the nodes are brought up.

- To re-provision the IE, in project_root on the local machine run `vagrant up node[1:3]`
- To re-configure the IE, in project_root/ansible on the PVM run `config-local.yml`

#### Staging

Staging IE is defined in Terraform plans.

- To provision staging IE, in project_root/terraform/staging on the PVM, run `tga`
- To configure staging IE, in project_root/ansible on the PVM, run `config-staging.yml`

#### Production

Production IE is defined in Terraform plans.


### AG blueprints

Prepd projects ship with a 'default' Application Group
AG blueprints are defined as Ansible playbooks


## Application Groups

For example, a Shopping Cart micro service is a project consisting of a backend application (Cart API) and a frontend application (Cart App)

Each application is its own git repository. An application can be of any language, may or may not require a database, etc


# Default infrastructure

## Development

The Vagrantfile (for local) and the Ansible playbooks (for all other environments) provision a Default Infrastructure
which creates a 3 node cluster with basic serivces

- node0: This is the primary machine for development and management of cluster services

## Local

- node0: Consul Server, Registrator, Nginx (ELB)
- node1: Consul, Registrator, Postgresql (RDS)
- node2: Consul, Registrator, Redis (Elasticache)
- node3: Consul, Registrator, DynamoDB


# Default Application Group

Prepd includes a Default Application Group. It includes the following files:

- default.yml  Settings for the Group, e.g. git repos, databases and a dictionary merge of inventory group vars and encrypted vars
- default-utils.yml  A playbook that defines common tasks, e.g. backing up and transfering a database from one IE to another
- default-development.yml  Configures the applications in the development IE
- default-local.yml  Installs the application into the local cluster
- default-staging.yml  Install the application into the staging cluster
- default-production.yml  Install the application into the production cluster

## Variables

### Locations

Variables are stored in either of two locations:
- inventory/group_vars/all
- inventory/group_vars/<environment>

The sub-directory matches either the name of the environment, e.g. development, local, staging or production

Variables are stored in either plain text files (vars.yml) or encrypted files (vault)

Examples:
- vars that apply to the local environment are located in `inventory/group_vars/local/vars.yml`
- encrypted vars that apply to all environemnts are located in `inventory/group_vars/all/vault`

Source code repositories and other develoment related info is stored default.yml

### Encrypted Variables

When creating a new project, prepd generates a uuid to be used as a secret passphrase for encyrypting vault files.
This passphrase is located in project_root/.vault_pass.txt which is listed in .gitignore so it is not committed to the repository.
Use the [ansible-vault](http://docs.ansible.com/ansible/playbooks_vault.html) command to edit an encrypted file, e.g.:

```bash
cd ansible
ansible-vault edit inventory/group_vars/all/vault
```

### Variables in Playbooks

Application variables, both plain text and encrypted, are merged together into a single dictionary hash name in default.yml
Each application has a key defined in the default.yml file.
The template generated by prepd contains keys for two applications: 'default_api' and 'default_app'.


# Utils

## Database Backup and Restore

TODO: Update these instructions

```bash
cd ansible
./db-utils --limit node0.staging --tags dump,fetch
./db-utils --limit node0.local --tags restore
```
