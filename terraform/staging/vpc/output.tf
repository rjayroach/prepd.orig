# staging/vpc/outputs.tf

output "subdomain_zone_id" {
  value = "${module.vpc.subdomain_zone_id}"
}

output "subnet_id" {
  value = "${module.vpc.subnet_id}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_security_group_ids" {
  value = "${module.vpc.vpc_security_group_ids}"
}
