# staging/default-api/main.tf

provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.region}"
}

data "terraform_remote_state" "global_route53" {
  backend = "s3"
  config {
    bucket = "${var.tf_remote_state_bucket}"
    key    = "global/route53/terraform.tfstate"
    region = "${var.tf_remote_state_region}"
  }
}

data "terraform_remote_state" "global_iam" {
  backend = "s3"
  config {
    bucket = "${var.tf_remote_state_bucket}"
    key    = "global/iam/terraform.tfstate"
    region = "${var.tf_remote_state_region}"
  }
}

data "terraform_remote_state" "staging_vpc" {
  backend = "s3"
  config {
    bucket = "${var.tf_remote_state_bucket}"
    key    = "staging/vpc/terraform.tfstate"
    region = "${var.tf_remote_state_region}"
  }
}


module "default-api" {
  source                 = "../../modules/app-server-with-elb"

  # Instance parameters
  application             = "${var.application}"
  environment             = "${var.environment}"
  instance_type           = "${var.instance_type}"
  public_key              = "${file("${var.public_key}")}"
  region                  = "${var.region}"
  route53_hostname        = "${var.hostname}"
  route53_primary_zone_id = "${data.terraform_remote_state.global_route53.primary_zone_id}"
  route53_zone_id         = "${data.terraform_remote_state.staging_vpc.subdomain_zone_id}"
  server_cert_arn         = "${data.terraform_remote_state.global_iam.server_cert_arn}"
  subnet_id               = "${data.terraform_remote_state.staging_vpc.subnet_id}"
  vpc_id                  = "${data.terraform_remote_state.staging_vpc.vpc_id}"
  vpc_security_group_ids  = "${data.terraform_remote_state.staging_vpc.vpc_security_group_ids}"
}
