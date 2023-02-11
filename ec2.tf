module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "bastion_host"

  ami                    = "ami-0fe0b2cf0e1f25c8a"
  instance_type          = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name  #monitoring             = true
  vpc_security_group_ids = [aws_security_group.bastion_host_sg.id]
  subnet_id              = "subnet-0736d8572dba02cc5"
  associate_public_ip_address = true
  user_data = <<-EOF
                #!/bin/bash
                yum -y update
                sudo amazon-linux-extras install postgresql13
                ec2-user ALL=ALL NOPASSWD:ALL" >> /etc/sudoers
              EOF
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "generated_key" {
  key_name   =  "rds_bastion_host"
  public_key = tls_private_key.example.public_key_openssh
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

output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}