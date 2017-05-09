provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.region}"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "c2p4-terraform-up-and-running-state"

  # This block enables versioning on the S3 bucket, so that every update to a file in the bucket actually creates a new version of that file
  # This allows you to see and roll back to older versions at any time
  versioning {
    enabled = true
  }

  # When you set prevent_destroy to true on a resource, any attempt to delete that resource (e.g. by running terraform destroy) will cause Terraform to exit with an error.
  lifecycle {
    prevent_destroy = true
  }
}
