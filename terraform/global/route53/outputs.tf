output "primary_zone_id" {
  value = "${aws_route53_zone.primary.zone_id}"
}

# output "route53_mx_arn" {
#   value = "${aws_route53_record.mx.arn}"
# }
