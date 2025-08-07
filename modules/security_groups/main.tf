terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

variable "project_name" {
  description = "The name of the project for tagging resources."
  type        = string
}

resource "aws_security_group" "sg1" {
  name        = "${var.project_name}-sg1-bastion-access"
  description = "Allow SSH from Tools EC2 to Bastion/Jumpbox"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from Tools EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.tools_ec2_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg1-bastion-access"
    Project = var.project_name
    Role    = "BastionAccess"
  }
}

resource "aws_security_group" "sg2" {
  name        = "${var.project_name}-sg2-application"
  description = "Application Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from sg1 (Bastion)"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg1.id]
  }
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Kubernetes API server (example)"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Allow from within the VPC
  }
  ingress {
    description = "NodePort services (example)"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Allow from within the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg2-application"
    Project = var.project_name
    Role    = "Application"
  }
}
