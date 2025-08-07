variable "vpc_id" {
  description = "The ID of the VPC where security groups will be created."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC."
  type        = string
}

variable "tools_ec2_ip" {
  description = "The CIDR block or IP for the tools EC2 instance (e.g., 'x.x.x.x/32')."
  type        = string
}