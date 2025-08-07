terraform {
  required_version = ">= 1.0.0" # Ensure that the Terraform version is 1.0.0 or higher

  required_providers {
    aws = {
      source = "hashicorp/aws" # Specify the source of the AWS provider
      version = "~> 4.0"        # Use a version of the AWS provider that is compatible with version
    }
  }
}

provider "aws" {
  region = "us-east-1" # Set the AWS region to US East (N. Virginia)
}

resource "aws_instance" "jump_box" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [var.sg1_id]
  key_name               = var.key_name

  tags = {
    Name = "jump-box"
  }
}

resource "aws_instance" "k8s_node1" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id
  vpc_security_group_ids = [var.sg2_id]
  key_name               = var.key_name

  tags = {
    Name = "k8s-node1"
  }
}

resource "aws_instance" "k8s_node2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id2
  vpc_security_group_ids = [var.sg2_id]
  key_name               = var.key_name

  tags = {
    Name = "k8s-node2"
  }
}
