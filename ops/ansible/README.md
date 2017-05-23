# Initialize Existing Project

After cloning prepd into a specific project directory then clone the submodules

```bash
cd project_name/ops/ansible
./init.yml
```

# Initialize and Setup New Project

After cloning prepd into a specific project directory then clone the submodules

```bash
cd project_name/ops/ansible
git remote rename origin upstream
git remote add origin git_remote_url
./init.yml
```

After initializing project, then set it up

```bash
cd project_name/ops/ansible
vi group_vars/all/setup.yml
./setup.yml
```
