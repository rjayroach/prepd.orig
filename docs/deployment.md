
# Deployment

## Monolithic Infrastructure and Application

For cases where the application is dependent on a specific set of infrastructure and that
infrastructure is dedicated to the application so they for an indivisible component


### Define and Configure

1. Define the Infrastructure for the Application

The infrastructure is defined in a subdirectory of terraform/components named after the application, e.g. 'default'

```bash
cd ~/prepd/terraform
vi components/default/main.tf
```

2. Set configuration values for the Infrastructure and Application

```bash
cd ~/prepd/ansible
vi group_vars/all/default.yml
vi inventory/staging/ec2.ini
ave group_vars/staging/vault
vi apps/default/tasks/main.yml
```


### Spin Up the Monolith

1. Use Ansible to configure Terraform

```bash
cd ~/prepd/ansible
./config-provisioner.yml
./default-provisioner.yml -i inventory/staging
```

2. Bring up the Infrastructure

```bash
cd ~/prepd/terraform/staging/default
tgp
```

3. Use Ansible to configure the infrastructure

```bash
cd ~/prepd/ansible
./config-master.yml -i inventory/staging
```

4. Use Ansible to deploy the application

```bash
cd ~/prepd/ansible
./default-master.yml -i inventory/staging
```


## Decoupled Infrastructure and Applications

This would apply in cases such as a Kubernetes cluster is provisioned and made available for applications which come later

### Infrastructure

### Applications

