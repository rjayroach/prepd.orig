output "lb_address" {
  value = "${aws_elb.staging.public_dns}"
}
