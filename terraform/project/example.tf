# See: https://www.terraform.io/intro/getting-started/build.html

provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.region}"
}

# Debian Jessie
variable "amis" {
  type    = "map"
  default = {
    us-east-1      = "ami-c8bda8a2"
    ap-southeast-1 = "ami-73974210"
  }
}

# Route53
resource "aws_route53_zone" "primary" {
  name    = "primary-example.com."
  comment = "HostedZone created by Route53 Registrar and Managed by Terraform"
}

resource "aws_route53_record" "gmail_txt" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${aws_route53_zone.primary.name}"
  type    = "TXT"
  ttl     = "3600"
  records = ["google-site-verification=text verification code from google"]
}

resource "aws_key_pair" "ansible" {
  key_name   = "ansible"
  public_key = "${file("../../.id_rsa.pub")}"
}

resource "aws_instance" "example" {
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name = "ansible"
  tags {
    Environment = "staging"
    Name        = "rails-1"
    Role        = "cluster-node"
  }
}

# resource "aws_eip" "ip" {
#   instance = "${aws_instance.example.id}"
# }
# 
# output "ip" {
#     value = "${aws_eip.ip.public_ip}"
# }
