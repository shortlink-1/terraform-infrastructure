terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.53.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Create Security Group
resource "aws_security_group" "allow_jenkins" {
  name        = "allow_jenkins"
  description = "Allow Jenkins inbound traffic on port 8080, application traffic on port 8081, SSH on port 22, and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id
  
  # for Jenkins
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # for application
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # for SSH allows you to connect ec2 trought connect 
  ingress {
  from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_jenkins"
  }
}

# Create EC2 instance
resource "aws_instance" "my_server" {
  ami             = "ami-04b70fa74e45c3917"
  instance_type   = "t2.medium"
  security_groups = [aws_security_group.allow_jenkins.name]
  
  tags = {
    Name = "myserver"
  }

  root_block_device {
    volume_size = 20
  }
}
