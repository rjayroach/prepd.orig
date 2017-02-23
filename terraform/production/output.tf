
output "instance_ips" {
  value = ["${aws_instance.default-api-server.*.private_ip}"]
}
