# Ember cli-deploy

## Installing

- ember-cli-dotenv: allows to externalize variables to a .env file that is not committed to source code
- ember-cli-deploy: a wrapper around other plugins that actually do the work, e.g. S3
- ember-cli-deploy-build: repsonsible for packaging everything up for deployment
- ember-cli-deploy-s3: deploy the build bundle to AWS S3
- ember-cli-deploy-revision-data: generates a unique revision key for each deployment which is used by other plugins
- ember-cli-deploy-display-revisions: modifies the deploy list command to show deploy revisions
- ember-cli-deploy-s3-index: this allows ember deploy to fetch revisions from S3

```bash
ember install ember-cli-dotenv
ember install ember-cli-deploy
ember install ember-cli-deploy-build
ember install ember-cli-deploy-s3
ember install ember-cli-deploy-revision-data
ember install ember-cli-deploy-display-revisions
ember install ember-cli-deploy-s3-index
```

Installing ember-cli-deploy creates config/deploy.js


## Create S3 bucket for deployment

- Documented here: https://github.com/ember-cli-deploy/ember-cli-deploy-s3#minimum-s3-permissions
- Permissions need to be set on the bucket (done automatically by Terraform)
- The bucket name is defined in a Terraform var (currently as `${var.application}.staging.${var.domain}`)
- Note that the bucket-name in the permissions file needs to match the value of `${var.application}.staging.${var.domain}` (done automatically by Terraform)


## Configure deployment

### Place AWS Credentials in config/deploy.js

- Documented here: https://github.com/ember-cli-deploy/ember-cli-deploy-s3#quick-start
- Terraform writes the credentials to /tmp/s3_bucket_credentials.yml
- Manually copy the values from that file to inventory/group_vars/all/vault
- run app-development.yml to write out the env file

### config/deploy.js

This has settings for multiple environments. Make changes here to configure the deployment

```js
module.exports = function(deployTarget) {
  var ENV = {
    build: {}
    s3: {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      bucket: process.env.AWS_BUCKET,
      region: process.env.AWS_REGION,
    }
  };
```


## Deploy

- Package everything in project_root/dists which is then ready to be deployed

```bash
ember build deploy  # this command can be skipped as ember deploy also does the build
```

- Deploy to staging

```bash
ember deploy staging
```

- List staging deployments

```bash
ember deploy:list staging
```

- Activate application on staging

```bash
ember deploy:activate staging --rev <the hash of the build>
```

OR use aliases:

```bash
eds         # ember deploy staging
edls        # ember deploy:list staging
edas <hash> # ember deploy:activate staging --rev <hash>
```

## Access the application

http://{app-name}.staging.{domain}


## ENVs

### Setting values for the applications

- API Server: The environment is set with tags on an EC2 or as a var in ansible's inventory/group_vars to generate
a set of ENVs with the correct values for the particular infrastructure environment

- Ember: Ember is always deployed from the development machine so the env strategy used for server deployment doesn't work
Therefore in Ember's config/deploy.js and config/environment.js the env vars are postfixed with the environment, e.g. `AWS_REGION_PRODUCTION`
Terraform generates Route53 entries for hostnames and writes values out to ansbile/group_vars/INFRASTRUCTURE_ENV/vault
The env role then needs to be run from a playbook to generate the .env file in Ember's project_root

### Envrionment ENVs

- Local development: An ENV file is generated for the API Server and written to the application's root directory.
The application is responsible for loading the ENV file

- Staging and production:  ENV vars come from ansible's inventory/group_vars and are passed to docker-compose vi the {app-name}-application.yml file


### DNS

- each environment has it's own VPC and sub-domain, e.g. staging
- the application is served from an S3 bucket which responds to application.environment.domain
- the API server is behind an ELB which is mapped to application-api.environment.domain
- CORS also needs to be setup in Rails that allows app.staging.example.com
