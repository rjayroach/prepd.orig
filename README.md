# Prepd

Prepd - A Production Ready Environment for Project Development

One of the core principles of Agile Development is delivering viewable results
to the business from Week 1. Too often product developement begins with the
application software, while the infrastructure to deploy into is addressed as
and when it is needed.

Thankfully, many web application products get to market on similar,
if not identical, infrastructure. However setting up this infastructure takes time,
is error prone and typically is non-repeatable ending up as a unique snowflake.

To avoid this, many development teams turn to a PaaS service such as Heroku.
This has limitations and only addresses the final deployment infrastructure.

Prepd aims to address this by providing a 'convention over configruation' approach
to provisioning infrastructure. From local developer machines (vagrant running linux
on the developer's laptop) to staging and production running a docker swarm cluster.

With microservices becoming a common application development strategy, prepd
aims to make it dead simple to build and deploy a microservice based application.
Beginning with the end in mind, Prepd offers a simple, conventional way to provision
all this infrastructure, including CI workflow, secrets managment, 12-factor apps

Agile Development requires 'near production' infrastructure to be in place from Day 1.
Using Prepd, makes that possible quickly and easily without resorting to a PaaS provider.

## Focus

The focus of Prepd is on enabling developers to build and deploy applications following current
industry best practices with as little effort as possible. Being flexible and configurable
for the wide variety of application deployment strategies is currently a secondary goal to
getting something up and running. Therefore, choices are made:

1. Infrastructure is provisioned via:
..* Vagrantfile on local machines for development and a local cluster
..* Terraform plans for clutser infrastructure exclusively on AWS
2. Ansible is the automation tool used to configure the infrastructure for application deployment
3. Docker conatainer deployment is currently the only method for deploying applications
4. The development environment currently supports:
..* Postgres and Redis for data storage
..* Rails and Ember for application development

A future goal for Prepd is to enable more application types and tool support

# What is a Production Ready Environment?

It takes a lot of services tuned to work together to make smoothly running infrastructure

## Networking
- Domain names figured out and DNS running on Route53 etc
- Ability to programatically change and update DNS
- SSL certs are already installed so we do TLS from the beginning on all publicly available infrastructure
- Load Balancing is setup, configured and running in at least staging and production, but also possible in development

## Development Pipeline Required Services

Prepd provisions and configures the infrastructure and provides a tool to deploy applications into the infrastructure.
However, certain aspects of the pipeline are expected to be provided outside of Prepd, which are:

- Continuous Integration
- Container Build and Store

### Continuous Integration

CI is expected to be setup and configured as part of an automated deploy process from the outset of the project.
Here is an example overview of using CircleCI to test a Rails API application

- Create an account on CircleCI and link it to your GitHub account. Authorize CircleCI to access the account
- Add the Rails API repository as a project on CircleCI. If using rails-templates a circle.yml project already exists
- Configure slack notifications for when a build completes

### Container Build and Store

A container repository that also builds containers is expected to be provided.
Here is an example overview of using quay.io to build a Rails API application container

- Create an account on quay.io and link it to your GitHub account. Authorize quay.io to access the account
- Add the Rails API repository as a docker repository on quay.io
- Create a trigger to build the container when there is a push on a certain branch of the GitHub repository

Prepd provides ansible playbooks that invoke docker compose to deploy the container from quay.io to the target infrastructure

## Application Services (TODO)

Prepd will be augmented to provide playbooks for the default Application Group as well as Terraform plans that provide:

- Communication Services, e.g. SMTP, SNS (Push), Slack webhooks, Twilio, etc
- Logging in both local/development and in staging/production with ELK
- Monitoring/alert service (Prometheus)
- Additional common 3rd party services as needed

## Swarm Load Balancing
- network overlays
- load balancing between micro services
- manage cluster scaling with compose/swarm mode/ansible or some combination thereof


# Installation

Prepd is a ruby gem. It also requires software on the local laptop, including VirtualBox, Vagrant and Ansible

```bash
gem install prepd
```

## Automated Installation of Dependencies (TODO)

With the gem installed, navigate to it's directory and run bootstrap.sh to install dependencies

```bash
bundle cd prepd
./bootstrap.sh
```

This will:

- Install ansible
- Clone the ansible-roles repository
- Run ansible to install Virtualbox and Vagrant

## Manual Installation of Dependencies

### Ansible

Tested with version 2.2.0

#### Install on MacOS

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

#### Install on Ubuntu

```bash
apt-get install ansible
```

### VirtualBox

Install VirtualBox from [here](https://www.virtualbox.org/wiki/Downloads)

### Vagrant

Install Vagrant from [here](https://www.vagrantup.com/docs/installation/)

```bash
vagrant plugin install vagrant-vbguest      # keep your VirtualBox Guest Additions up to date
vagrant plugin install vagrant-cachier      # caches guest packages
vagrant plugin install vagrant-hostmanager  # updates /etc/hosts file when machines go up/down
```

#### vagrant-hostmanager
This plugin automatically updates the host's /etc/hosts file when vagrant machines go up/down

In order to do that it needs sudo password or sudo priviledges.
To avoid being asked for the password every time the hosts file is updated,
[enable passwordless sudo](https://github.com/devopsgroup-io/vagrant-hostmanager#passwordless-sudo)
for the specific command that hostmanager uses to update the hosts file


# Prepd Actors

A Client may have multiples projects. Applications share common infrastructure that is defined by the Project

- Client: An organization with one or more projects, e.g Acme Corp
- Project: A definition of infrastructure provided for one or more applications
- Application: A logical group of deployable repositories, e.g. a Rails API server and an Ember web client


## Projects

- A project is comprised of Infrastructure Environments (IE) and Application Groups (AG)
- Infrastructure Environemnts are defined separately for each environment
- Application Groups are deployed into one or more Infrastructure EnvironmentS

## Infrastructure Environments

Infrastructure is either Vagrant machines for development and local environments or EC2 instances for staging and production

Local, Staging and Production Environments use a Docker swarm network to manage applicaiton groups

- local: virtual machines running on laptop via vagrant whose primary purpose is application development
- development: primary purpose is also application development, but the infrastructure is deployed in the cloud (AWS)
- staging: a mirror of production in every way with the possible exception of reduced or part-time resources
- production: production ;-)

## Applications

Applications are the content that actually gets deployed. The entire purpose of prepd is to provide a consistent
and easy to manage infrastructure for each environment into which the application will be deployed.


# Usage

## New Client

This overview assumes a complete greenfield, e.g. that no infrastructure exists, no applications exist or even 3rd
party service have been setup. To start from zero, then:

- Create a new GH Organization
- Create an AWS Account and two IAM Groups: Administrators and ReadOnlyAdministrators
- Create a CI Account and give it access to the GH Organization
- Create a Docker Private Repository account and give it access to the GH Organization
- Create the project in prepd

The first four items are outside the scope of this document.

```ruby
prepd
c = Client.create(name: 'Acme')
```

## New Project
- create a GH repo for the project
- create an IAM user for project_name-terraform and download the AWS credentials CSV
- create an IAM user for project_name-ansible and download the AWS credentials CSV
- use prepd to create the project using the repo_url and path names (tf_creds and ansible_creds) to CSV files

```ruby
c = Client.find_by(name: 'Acme')
c.projects.new(name: 'widget', repo_url: 'git@github.com:my_git_hub_account/widget.git')
c.tf_creds = 'Users/dude/aws/widget-terraform.csv'
c.ansible_creds = 'Users/dude/aws/widget-ansible.csv'
c.save
```

## New Application

View the [lego README.md](https://github.com/rjayroach/lego) on creating micro serivce applications with Rails and Ember

## Bring Up the Machine

```ruby
cd ~/prepd/acme/widget
vagrant up
vagrant ssh
```


# Credentials

## Project Credentials
Prepd will create the following credential (hidden) files in project_root:

- .boto: AWS IAM credentials that give read only access to Ansible
- .developer.yml: Developer’s git account (and other account) details
- .terraform-vars.txt: AWS IAM credentials that give full access to CRUD AWS resources
- .vault-password.txt: a UUID used to encrypt and decrypt ansible vault files
- .id_rsa.pub: the public key uploaded to AWS as the primary key pair for accessing EC2 instances
- .id_rsa: the private key

- terraform will use project_root/id_rsa.pub to upload key_material to AWS for the machine key
- config-development.yml checks the project_root and: 1) if .boto exists link it, 2) if id_rsa and id_rsa.pub exist then link them
- the developer can then do ssh-add which will auto load ~/.ssh/id_rsa to login or run ansible


## Transfer Credentials to New Machine

The prepd gem can encrypt the credentials using gpg which must be installed on the host machine

The encrypted credentials are written to and read from the user's home directory so that they are not accidentally
committed to the project repository

### Encrypt

```ruby
prepd
c = Client.find_by(name: 'Acme')
p = c.projects.find_by(name: 'widget')
p.encrypt
```

This will create a tar file containing the various project credentials. It will then invoke gpg to encrypt the archive.
The credentials will be placed in the project's data directory

You will be prompted for a passphrase to enter twice. After doing that send the file by email or other mechanism

### Decrypt

On the target machine, use prepd to decrypt the file and place it in the correct directory

- Clone the project repository
- Place the gpg tar file in the project's data directory
- Run prepd. It will expect to find the credentials file in the project's data directory

```ruby
prepd
c = Client.find_by(name: 'Acme')
p = c.projects.find_by(name: 'widget')
p.decrypt
```

## Authorization

If giving a developer access to the machine for development only (not terraform or ansible) then add their public key to the
instance’s ~/.ssh/authorized_keys. The developer uses ssh-agent forwarding to access the machine from the VM


# Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/prepd. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


# License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
