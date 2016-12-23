variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "region" {
  default = "ap-southeast-1"
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}
