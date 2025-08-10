provider "aws" {
  region = "eu-west-1"
}

resource "aws_security_group" "sg1" {
  name        = "Ss86-sg1-bastion-access"
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
    Name    = "Ss86-sg1-bastion-access"
    Role    = "BastionAccess"
  }
}

resource "aws_security_group" "sg2" {
  name        = "Ss86-sg2-application"
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
  ingress {
    description = "Calico BGP Peering (node-to-node)"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Calico IP-in-IP (node-to-node)"
    from_port   = -1
    to_port     = -1
    protocol    = "4" # Protocol number for IP-in-IP
    self        = true
  }

  ingress {
    description = "Kubelet API (10250) from other nodes in this SG (control-plane to worker)"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "Ss86-sg2-application"
    Role    = "Application"
  }
}
