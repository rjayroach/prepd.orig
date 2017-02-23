# Terraform


Used to provision AWS resources primarily for staging and production Infrastructure Environments and occasionally for development

Terraform Templates (tf) define the infraststructure


## One Time Configuration

After creating the project then:

- a bucket name for state must be created. It must be globally unique within the AWS infrastructure


## State

Terraform State (tfstate) is stored in hidden sub-directories of the directory in which you run the templates

State is necessary because on each run terraform will query AWS for the current state of the resource defined in the template.
It then compares the actual state with the known state (tfstate) and updates the Infrastructure based on the difference

State is stored remotely on an encrypted S3 bucket

## Using

You must run terraform in a directory which has templates in it. It does not search sub-directories
Every directory that has terraform templates will store it's state in hidden files in that directory

Each directory reads its own .terragrunt file so to avoid duplication we use a top level .terragrunt file and reference it from the sub-directory using

  find_in_parent_folders()

This helper method returns the path to the first .terragrunt file it finds in the parent folders above the current .terragrunt file
See: https://github.com/gruntwork-io/terragrunt#find_in_parent_folders-helper

In addition, this top level file needs to write state information to the correct sub-directory. It gets that information using

  path_relative_to_include()

This helper returns the relative path to the top level .terragrunt file and the path specified in its include block
See https://github.com/gruntwork-io/terragrunt#path_relative_to_include-helper


## Configuration
There is a global .terragrunt file
It configures Terraform to automatically store tfstate files in S3

bucket_name must be in ~/.terraform-vars.txt and in ~/prepd/terraform/.terragrunt
