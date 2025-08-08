variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "eu-west-1"
}

variable "project" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "SS86"
}

########### VPC variables ############################
variable "vpc_cidr" {
  type = string
}

variable "public_subnet1_cidr" {
  type = string
}

variable "public_subnet2_cidr" {
  type = string
}

variable "private_subnet1_cidr" {
  type = string
}

variable "private_subnet2_cidr" {
  type = string
}

variable "availability_zone1" {
  type = string
}

variable "availability_zone2" {
  type = string
}

#################### SG variables  #######################
variable "tools_ec2_ip" {
  type = string
}

#################### EC2 variables ################
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

variable "private_subnet_id" {
  description = "The ID of the private subnet for k8s-node1."
  type        = string
}

variable "private_subnet_id2" {
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