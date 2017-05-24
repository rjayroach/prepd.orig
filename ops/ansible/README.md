# Initialize Project

## Existing Project

After cloning prepd into a specific project directory then clone the submodules

```bash
cd project_name/ops/ansible
./init.yml
```

## New Project

After cloning prepd into a specific project directory then clone the submodules

```bash
cd project_name/ops/ansible
git remote rename origin upstream
git remote add origin git_remote_url
git branch -u origin/master
./init.yml
```

After initializing project, then set it up

```bash
cd project_name/ops/ansible
vi group_vars/all/project.yml; modify the setup hash to reflect your environments and roles
./setup.yml
```

After setting up the project, set up credentials

```bash
vi ../../credentials/developer.yml
./setup.yml -t credentials
```

NOTE: If using provisioning make sure that the value for boto-config in group_vars/all/setup.yml is
the same as the value in project_dir/credentials/developer.yml

## Provision Infrastructure

group_vars/all/provisioner/vpc.yml

```bash
./provisioner.yml -i inventory/staging -t vpc
```

## Project

group_vars/all/project.yml
