provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.region}"
}


# Create a VPC to launch instances into
resource "aws_vpc" "staging" {
  cidr_block = "172.16.0.0/20"
  tags {
    Application = "recheck"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "staging" {
  vpc_id = "${aws_vpc.staging.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.staging.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.staging.id}"
}

# Create a subnet to launch instances into
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.staging.id}"
  cidr_block              = "172.16.1.0/24"
  map_public_ip_on_launch = true
}

# Application Security Group
resource "aws_security_group" "appserver" {
  name        = "appserver"
  description = "AppServer Security Group"
  vpc_id      = "${aws_vpc.staging.id}"
  tags {
    Application = "replace-me"
  }

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # port 3000 from ELB
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
# TODO: only accept traffic from the ELB
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ELB Security Group
resource "aws_security_group" "elb" {
  name        = "appserver-elb"
  description = "ELB Security Group"
  vpc_id      = "${aws_vpc.staging.id}"
  tags {
    Application = "recheck"
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# TODO: Change to an ALB
resource "aws_elb" "staging" {
  name                      = "staging-appserver-elb"
  security_groups           = ["${aws_security_group.elb.id}"]
  subnets                   = ["${aws_subnet.public.id}"]
  cross_zone_load_balancing = true

  listener {
    instance_port      = 3000
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    # lb_port            = 443
    # lb_protocol        = "https"
    # ssl_certificate_id = "${aws_iam_server_certificate.star_rhodesedge_com_cert.arn}"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    # target            = "HTTP:8000/"
    target              = "TCP:3000"
    interval            = 30
  }

  tags {
    Application = "recheck"
    Environment = "staging"
    Name        = "elb-1"
  }
}

resource "aws_route53_zone" "staging" {
  name = "staging.c2p4.com"
  tags {
    Environment = "staging"
  }
}

data "terraform_remote_state" "global_route53" {
  backend = "s3"
  config {
    bucket = "c2p4-terraform-up-and-running-state"
    key    = "global/route53/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# Add NS records for the subdomain to the parent domain
resource "aws_route53_record" "staging-ns" {
  # zone_id = "${aws_route53_zone.zone_id}"
  # zone_id = "${aws_route53_zone.staging.zone_id}"
  zone_id = "${data.terraform_remote_state.global_route53.primary_zone_id}"
  name    = "staging.c2p4.com"
  type    = "NS"
  ttl     = "30"
  records = [
    "${aws_route53_zone.staging.name_servers.0}",
    "${aws_route53_zone.staging.name_servers.1}",
    "${aws_route53_zone.staging.name_servers.2}",
    "${aws_route53_zone.staging.name_servers.3}"
  ]
}

# Map Route53 DNS record to the ELB
resource "aws_route53_record" "recheck" {
  zone_id = "${aws_route53_zone.staging.zone_id}"
  name    = "app.${aws_route53_zone.staging.name}"
  type    = "A"
  # TTL for all alias records is 60 seconds, you cannot change this, therefore ttl is omitted in alias records
  alias {
    name = "${aws_elb.staging.dns_name}"
    zone_id = "${aws_elb.staging.zone_id}"
    evaluate_target_health = true
  }
}
