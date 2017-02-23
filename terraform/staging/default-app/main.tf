# staging/default-app/main.tf

provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.region}"
}

# data "terraform_remote_state" "global_iam" {
#   backend = "s3"
#   config {
#     bucket = "${var.tf_remote_state_bucket}"
#     key    = "global/iam/terraform.tfstate"
#     region = "${var.tf_remote_state_region}"
#   }
# }

data "terraform_remote_state" "staging_vpc" {
  backend = "s3"
  config {
    bucket = "${var.tf_remote_state_bucket}"
    key    = "staging/vpc/terraform.tfstate"
    region = "${var.tf_remote_state_region}"
  }
}

# Ember application's S3 bucket parameters
module "default-web" {
  source           = "../../modules/s3-website"

  allowed_ip       = "${var.website_allowed_hosts}"
  application      = "default-web"
  bucket_name      = "${var.bucket_name}"
  credentials_file = "${var.credentials_file}"
  environment      = "staging"
  region           = "${var.region}"
  route53_zone_id  = "${data.terraform_remote_state.staging_vpc.subdomain_zone_id}"
}
