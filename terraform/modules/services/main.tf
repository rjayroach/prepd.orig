# Debian Jessie
variable "amis" {
  type    = "map"
  default = {
    us-east-1      = "ami-c8bda8a2"
    ap-southeast-1 = "ami-73974210"
  }
}

# TODO: move to global OR rename the keypair to ansible-staging
resource "aws_key_pair" "ansible" {
  key_name   = "ansible"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "example" {
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name      = "ansible"
  tags {
    Environment = "staging"
    Name        = "node1"
    Role        = "cluster-node"
  }
}
