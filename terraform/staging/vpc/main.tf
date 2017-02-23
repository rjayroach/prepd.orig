# staging/vpc/main.tf

provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.region}"
}

data "terraform_remote_state" "global_iam" {
  backend = "s3"
  config {
    bucket = "${var.tf_remote_state_bucket}"
    key    = "global/iam/terraform.tfstate"
    region = "${var.tf_remote_state_region}"
  }
}

data "terraform_remote_state" "global_route53" {
  backend = "s3"
  config {
    bucket = "${var.tf_remote_state_bucket}"
    key    = "global/route53/terraform.tfstate"
    region = "${var.tf_remote_state_region}"
  }
}

module "vpc" {
  source          = "../../modules/vpc"

  # VPC parameters
  domain          = "${var.domain}"
  environment     = "${var.environment}"
  primary_zone_id = "${data.terraform_remote_state.global_route53.primary_zone_id}"
}
