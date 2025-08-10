provider "aws" {
  region = "eu-west-1" # This might be inherited if this code is part of a larger configuration/module
}

resource "aws_key_pair" "imported_tf_managed" {
  key_name   = "tf-managed-key"
  public_key = file("./modules/ec2/files/id_rsa.pub") # encrypted with ansible-vault
}

resource "aws_instance" "jump_box" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.sg1_id]
  key_name               = aws_key_pair.imported_tf_managed.key_name
  associate_public_ip_address = true

  tags = {
    Name    = "${var.project_name}-jump-box"
    Project = var.project_name
    Role    = "JumpBox"
  }
}

resource "aws_instance" "k8s_node1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet1_id
  vpc_security_group_ids = [var.sg2_id]
  key_name               = aws_key_pair.imported_tf_managed.key_name

  tags = {
    Name    = "${var.project_name}-k8s-node1"
    Project = var.project_name
    Role    = "KubernetesNode"
    Index   = "1" # identify K8s nodes by index
  }
}

resource "aws_instance" "k8s_node2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet2_id
  vpc_security_group_ids = [var.sg2_id]
  key_name               = aws_key_pair.imported_tf_managed.key_name

  tags = {
    Name    = "${var.project_name}-k8s-node2"
    Project = var.project_name
    Role    = "KubernetesNode"
    Index   = "2" # identify K8s nodes by index
  }
}
