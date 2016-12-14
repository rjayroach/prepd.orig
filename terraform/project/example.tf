# See: https://www.terraform.io/intro/getting-started/build.html

provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.region}"
}

# Debian Jessie
variable "amis" {
  type = "map"
  default = {
    us-east-1 = "ami-c8bda8a2"
    ap-southeast-1 = "ami-73974210"
  }
}

resource "aws_key_pair" "ansible" {
  key_name = "ansible"
  public_key = "${file(../../.id_rsa.pub)}"
}

resource "aws_instance" "example" {
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name = "ansible"
  tags {
    Application = "development"
    Environment = "staging"
    Name = "rails-1"
    Role = "app-server"
  }
}

# resource "aws_eip" "ip" {
#   instance = "${aws_instance.example.id}"
# }
# 
# output "ip" {
#     value = "${aws_eip.ip.public_ip}"
# }
