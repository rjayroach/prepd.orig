


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

## New Application

View the [lego README.md](https://github.com/rjayroach/lego) on creating micro serivce applications with Rails and Ember

