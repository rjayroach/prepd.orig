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
git push -u origin master
./init.yml
```

After initializing project, then set it up

```bash
cd project_name/ops/ansible
vi group_vars/all/project.yml #  modify the setup hash to reflect your environments, roles and credentials
./setup.yml
```

After setting up the project, set up credentials

```bash
vi ../../credentials/developer.yml
./setup.yml # Run setup again to write out credentials to ~/.aws/credentials and project_dir/credentials
```

NOTE: If using provisioning make sure that the value for boto-config in group_vars/all/project.yml is
the same as the value in project_dir/credentials/developer.yml

## Project

group_vars/all/project.yml

## Provision Infrastructure

group_vars/all/provisioner.yml

```bash
./provisioner.yml -i inventory/staging -t vpc
```

# Push changes to upstream

If tracking upstream, to add changes to both origin and upstream:

make changes on master and commit only those changes that will apply to both master and upstream

```bash
git log # get the hash of the last commit
git co -b feature-name upstream/master
git cherry-pick hash
git push
git checkout master
```
