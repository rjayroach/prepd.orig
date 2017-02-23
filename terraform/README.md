# Terraform

Used to provision AWS resources for development, staging and production Infrastructure Environments

Terraform Templates (tf) define the infraststructure

## State

Terraform State (tfstate) is stored in hidden sub-directories of the directory in which you run the templates

State is necessary because on each run terraform will query AWS for the current state of the resource defined in the template.
It then compares the actual state with the known state (tfstate) and updates the Infrastructure based on the difference

State is stored remotely on an encrypted S3 bucket




## EC2 Key Pair
- Terraform does not create key pairs and can only upload an existing key pair
- key pairs in AWS are stored by region so it makes sense to generate a key pair on the localhost and upload the key_material to AWS as necessary per region
- Terraform is the single tool to manage infrastructure so it must upload the key pair
- Ansible is the single tool to configure instances so it needs the key pair in order to access and configure them
- only prepd or manual transfer is what creates and/or gives access to credentials
- credentials are *never* stored in a repo including in an encrypted vault
