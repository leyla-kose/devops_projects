terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.12.1"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners = ["amazon"] 

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  filter {
    name           = "owner-alias"
    values         = ["amazon"]
  } 
}

variable "keyname" {
  default = "firstkey"
}

resource "aws_instance" "my-ec2" {
  ami           = data.aws_ami.amazon_linux2.id
  instance_type   = "t2.micro"
  key_name        = var.keyname
  security_groups = [ "tf-ec2-sg" ]
  tags = {
    Name = "Kittens-EC2"
  }
  user_data = file("./user_data.sh")
} 

resource "aws_security_group" "ec2-sg" {
  name = "tf-ec2-sg"
  description = "ssh and http"
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 22
      protocol = "tcp"
      to_port = 22
      cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
      from_port = 0
      protocol = -1
      to_port = 0
      cidr_blocks = [ "0.0.0.0/0" ]
  }
}


output "my-ec2-public-ip" {
  value = aws_instance.my-ec2.public_ip
}