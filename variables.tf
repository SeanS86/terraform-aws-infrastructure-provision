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
  type        = string
}

################# Load balancer variables  ################
variable "dashboard_node_port" {
  description = "The NodePort assigned to the Kubernetes Dashboard service (kubernetes-dashboard-kong-proxy)."
  type        = number
}
