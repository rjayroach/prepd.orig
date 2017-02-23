variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "rds_instance_name" {}
variable "rds_allocated_storage" {}
variable "rds_engine_type" {}
variable "rds_engine_version" {}
variable "database_name" {}
variable "database_user" {}
variable "database_password" {}
variable "rds_security_group_id" {}
variable "db_parameter_group" {}

// DB Subnet Group Inputs
variable "subnet_az1" {}
variable "subnet_az2" {}
