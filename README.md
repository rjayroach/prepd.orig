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

# A Production Ready Environment Defined

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


# Getting Started

## Setup

Prepd requires VirtualBox, Vagrant and Ansible to be installed on the local machine.
See [this document](https://github.com/rjayroach/prepd/blob/master/docs/install-dependencies.md) for steps to install those dependencies

Create a parent directory for the organization or client which will have a sub-directory for the project(s)

```bash
mkdir -p ~/projects/my-client
```

### Start on a New Project

Clone this repository into the organization directory

```bash
cd ~/projects/my-client
git clone git@github.com:rjayroach/prepd.git awesome-project
```

### Start on an Existing Project

Clone the existing project into the organization directory and pull the git submodules

```bash
cd ~/projects/my-client
git clone project-url
cd project-name
git submodule update --init --recursive
```


## Connect to the Project VM

1. Start the VM

Note that the first time the machine is booted it will take several minutes to configure tooling, etc.

```bash
cd awesome-project
vagrant up
```

2. Connect to the VM

Before connecting, ensure you have loaded your ssh key into ssh agent so that you can access git repostories from inside the VM
The VM will have a unique hostname following this nomenclature: node0.project-name.organization-name.local

If you have configured ssh for connections to the .local domain then:

```bash
ssh-add
ssh node0.awesome-project.my-client.local
```

Otherwise, use vagrant to connect:

```bash
ssh-add
cd ~/projects/my-client
vagrant ssh
```

3. If you cloned an existing project then you need to [copy product credentials](https://github.com/rjayroach/prepd/blob/master/credentials/README.md#decrypt) to your VM


## Develop your Project

1. See [understanding prepd components](https://github.com/rjayroach/prepd/blob/master/docs/README.md)
2. See [deploy your application](https://github.com/rjayroach/prepd/blob/master/docs/deployment.md)


# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rjayroach/prepd. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


# License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
