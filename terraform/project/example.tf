# See: https://www.terraform.io/intro/getting-started/build.html

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
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

resource "aws_instance" "example" {
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name = "rjayroach"
  tags {
    env = "development"
    role = "dev"
    c_role = "master"
  }
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.example.id}"
}

output "ip" {
    value = "${aws_eip.ip.public_ip}"
}

resource "aws_key_pair" "rjayroach" {
  key_name = "rjayroach"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNG7OD1ZoCDSG4DCRRSvWHMsbPjeXoSNZujnm6O59SQbh5uXt3bs93S86DslRCaL08n4LYrOmVwMfDCHZzIKuTs3jrisNeXi3Va4KhttK7J03omp7CVA+DaeC19fNQOioASBDyZmXuuvehVpXctuo6vq6cmyETirP7Dl/v+QNCZthWtpETdu/RXhyerLYlunFYfnVxhYi8St/8LXt/TNbnNImYD6QbpfTU6UGbWXdEGxv/Xm07pYeD/LTpNqbVaDEHcybDIMxRZ5Bt2lBmra+nctNF7jqs2VcVzqRhBNIXpnkDV+LoaunFMOFek8UF0sCfhA2DHKahkWwrS9bJg2EX rjayroach@gmail.com"
}
