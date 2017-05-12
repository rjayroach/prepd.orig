# Prepd Ops

Contains ansible playbooks, kubernetes definitions and terraform templates for managing your infrastructure


# Getting Started

## Bring up Prepd Runtime

```bash
mkdir ~/prepd/c2p4; cd ~/prepd/c2p4
git clone git@github.com:rjayroach/prepd.git projects
cd projects
vagrant up
```

## Create a Project

```bash
ssh node0.projects.c2p4.local
cd ~/prepd/ansible
vi new-project.yml # change the name of the project, etc in this file
./new-project.yml  # this creates the new project in the directory you indicated in previous step

cd project_dir
vi credentials/developer.yml

cd ops/ansible
./dev-servers -t config
```


## Configure Project

cd project_dir/ansible
vi roles/dev-server/vars/main.yml


# Applications

Each application has it's own namespace which contains subdirectories for ansible, kubernetes and terraform

```bash
.
└── app
    ├── ansible
    │   ├── ansible.cfg -> ../../../ansible/ansible.cfg
    │   ├── config.yml
    │   ├── deploy.yml
    │   ├── group_vars
    │   ├── inventory
    │   ├── provision.yml
    │   ├── roles
    │   ├── test.yml
    │   └── utils.yml
    ├── kubernetes
    └── terraform
        ├── README.md
        └── global
```
