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
