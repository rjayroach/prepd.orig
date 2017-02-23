resource "aws_security_group" "vpc-4b40b22d-bastion-host-inbound-from-internet" {
    name        = "bastion-host-inbound-from-internet"
    description = "Bastion host inbound from internet"
    vpc_id      = "vpc-4b40b22d"

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = "${var.bastion_host_permit_ip}"
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "vpc-4b40b22d-bastion-host-internal-interface" {
    name        = "bastion-host-internal-interface"
    description = "public subnet to private subnet communications"
    vpc_id      = "vpc-4b40b22d"

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "vpc-5524cd33-default" {
    name        = "default"
    description = "default VPC security group"
    vpc_id      = "vpc-5524cd33"

    ingress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        security_groups = []
        self            = true
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "vpc-4b40b22d-default" {
    name        = "default"
    description = "default VPC security group"
    vpc_id      = "vpc-4b40b22d"

    ingress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        security_groups = []
        self            = true
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "vpc-4b40b22d-launch-wizard-2" {
    name        = "launch-wizard-2"
    description = "launch-wizard-2 created 2016-11-30T11:59:55.372-05:00"
    vpc_id      = "vpc-4b40b22d"

    ingress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["10.0.1.0/24", "192.168.1.0/24"]
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        security_groups = ["sg-7aa62a06"]
        self            = false
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

