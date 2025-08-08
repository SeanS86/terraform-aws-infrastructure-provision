variable "project_name" {
  description = "The name of the project for tagging and naming resources."
  type        = string
}

variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instances."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance (e.g., t2.micro, m5.large)."
  type        = string
}

variable "public_subnet_id" {
  description = "The ID of the public subnet for the jump box."
  type        = string
}

variable "private_subnet1_id" {
  description = "The ID of the private subnet for k8s-node1."
  type        = string
}

variable "private_subnet2_id" {
  description = "The ID of the second private subnet for k8s-node2 (ensure this is different from private_subnet_id if they are meant to be in different subnets/AZs)."
  type        = string
}

variable "sg1_id" {
  description = "The ID of the security group for the jump box (sg1)."
  type        = string
}

variable "sg2_id" {
  description = "The ID of the security group for the Kubernetes nodes (sg2)."
  type        = string
}

variable "key_name" {
  description = "The name of the EC2 key pair to use for SSH access."
  type        = string
}