# Credentials

A primary design goal of prepd is to provide a mechanism for the efficient and safe management of security credentials
including cloud provider API keys, ssh keys used to access infrastructure and SSL certificates

This mechanism provides a convention over configuration approach to storing and securely transfering credentials in an
effort to avoid lost time and management hassles over storage of *all* security credentials related to the project

Prepd provides capability to have multiple keys; different key in each infrastructure type and/or environment
For example, a unique ssh key can be easily generated and stored for each bastion host individully
For the servers it can be convenient to have a single key which can be loaded into ssh-agent and forwarded to the bastion host (id_rsa)

## Getting Started

### Location

Prepd stores all credentials sub directories of the project_dir/credentials directory

```bash
credentials
├── aws
├── certs
└── keys
```

### New Project

When creating a new project you can follow these steps:

- In your AWS Account create two IAM Groups: Administrators (full access to all AWS resources) and ReadOnlyAdministrators (read only access to all AWS resources)
- create an IAM user named project_name-terraform, assign it to the Administrators Group and download the AWS credentials CSV to project_dir/credentials/aws/terraform.csv
- create an IAM user for project_name-ansible, assign it ot the ReadOnlyAdministrators Group and download the AWS credentials CSV to project_dir/credentials/aws/ansible.csv

### Project Credentials

When you boot the project runtime (vagrant up) prepd will create the following credential files in the project_root/credentials directory:

- developer.yml: Developer’s git account (and other account) details
- vault-password.txt: a UUID used to encrypt and decrypt ansible vault files
- id_rsa.pub: the default public key uploaded to AWS as the key pair for accessing EC2 instances
- id_rsa: the private key


## Using with Terraform

prepd stores tf creds in  credentials/terraform/terraform.tfvars

When running terraform, first export $AWS_PROFILE to specify the account to access the tf bucket. Use 'default'

NOTE: The tfvars file still needs to be used to specifiy different AWS accounts for the acutal plan apply

### Provisioning

- For behind the bastion host, create a generic ssh key pair in each AWS region
- For each bastion host, a unique key pair is created
- write the key to credentails/keys/hostname
- updates .ssh/config with the path to ssh keys
- update inventory/<service>vars to add ansible_private_ssh_path for the bastion host


## Transferring Credentials

In order to safely manage credentials there needs to be a simple, safe and standard mechansim for transferring credentials to a new developer.
You can use prepd to encrypt specific or all project credentials using gpg

The encrypted credentials are written to and read from the project_root/credentials so that they are not accidentally
committed to the project repository

NOTE: gpg must be installed on the host machine

### Encrypt

```ruby
pry -r ./prepd.rb
p.encrypt
```

This will create a tar file containing the various project credentials. It will then invoke gpg to encrypt the archive.

You will be prompted for a passphrase to enter twice. After doing that send the file by email or other mechanism

### Decrypt

On the target machine, use prepd to decrypt the file and place it in the correct directory

- Clone the project repository
- Place the gpg tar file in the project_root/credentials directory
- Run prepd. It will expect to find the credentials file in the project's data directory

```ruby
pry -r ./prepd.rb
p.decrypt
```

## Authorization

If giving a developer access to the machine for development only (not terraform or ansible) then add their public key to the
instance’s ~/.ssh/authorized_keys. The developer uses ssh-agent forwarding to access the machine from the VM


## New Client

This overview assumes a complete greenfield, e.g. that no infrastructure exists, no applications exist or even 3rd
party service have been setup. To start from zero, then:

- Create a new GH Organization
- Create a CI Account and give it access to the GH Organization
- Create a Docker Private Repository account and give it access to the GH Organization
- create a GH repo for the project
