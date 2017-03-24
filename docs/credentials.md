# Credentials

## What Is Needed

### New Client

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

### New Project
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
pry -r ./prepd.rb
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
pry -r ./prepd.rb
p.decrypt
```

## Authorization

If giving a developer access to the machine for development only (not terraform or ansible) then add their public key to the
instance’s ~/.ssh/authorized_keys. The developer uses ssh-agent forwarding to access the machine from the VM

