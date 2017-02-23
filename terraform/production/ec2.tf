
provider "aws" {
  # access_key = "${var.aws_access_key_id}"
  # secret_key = "${var.aws_secret_access_key}"
  # region     = "us-east-1" # "${var.region}"
  region     = "${var.region}"
}

resource "aws_instance" "bastion-host" {
    ami                         = "ami-29b38f3e"
    availability_zone           = "us-east-1d"
    ebs_optimized               = false
    instance_type               = "t2.micro"
    monitoring                  = false
    key_name                    = "Ansible"
    subnet_id                   = "subnet-xxxxb629"
    vpc_security_group_ids      = ["sg-xxxx2a06"]
    associate_public_ip_address = true
    private_ip                  = "10.0.0.184"
    source_dest_check           = true

    root_block_device {
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }

    tags {
        "Environment" = "production"
        "Application" = "default"
        "Name" = "bastion-host"
    }
}

resource "aws_instance" "default-api-server" {
    ami                         = "ami-29b38f3e"
    availability_zone           = "us-east-1d"
    ebs_optimized               = false
    instance_type               = "m3.medium"
    monitoring                  = false
    key_name                    = "Ansible"
    subnet_id                   = "subnet-xxxxb628"
    vpc_security_group_ids      = ["sg-xxxx184f"]
    associate_public_ip_address = false
    private_ip                  = "10.0.1.118"
    source_dest_check           = true

    root_block_device {
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }

    tags {
        "Name" = "default-api-server"
        "Application" = "default"
        "Environment" = "production"
    }
}

