module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "bastion_host"

  ami                    = "ami-0fe0b2cf0e1f25c8a"
  instance_type          = "t2.micro"
  #key_name               = "user1"
  #monitoring             = true
  vpc_security_group_ids = [aws_security_group.bastion_host_sg.id]
  subnet_id              = "subnet-0736d8572dba02cc5"
  associate_public_ip_address = true


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  
}

resource "aws_security_group" "bastion_host_sg" {
name = "bastion_host_sg"
vpc_id = "vpc-06fad1c1fabb92c78"
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }
// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}
