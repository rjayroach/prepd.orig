# output "lb_address" {
#   value = "${aws_alb.web.public_dns}"
# }

# output "ip" {
#     value = "${aws_eip.ip.public_ip}"
# }

output "instance_ips" {
  value = ["${aws_instance.example.*.public_ip}"]
}
