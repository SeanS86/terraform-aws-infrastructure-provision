output "vpc_id" {
  description = "The ID of the main VPC."
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the main VPC."
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The primary CIDR block of the main VPC."
  value       = module.vpc.vpc_cidr_block
}

output "vpc_default_route_table_id" {
  description = "The ID of the main VPC's default route table."
  value       = module.vpc.vpc_default_route_table_id
}

output "vpc_default_network_acl_id" {
  description = "The ID of the main VPC's default network ACL."
  value       = module.vpc.vpc_default_network_acl_id
}

output "vpc_default_security_group_id" {
  description = "The ID of the main VPC's default security group."
  value       = module.vpc.vpc_default_security_group_id
}

# --- Subnet Outputs ---
output "public_subnet1_id" {
  description = "The ID of public subnet 1."
  value       = module.vpc.public_subnet1_id
}

output "public_subnet1_arn" {
  description = "The ARN of public subnet 1."
  value       = module.vpc.private_subnet1_arn
}

output "public_subnet1_cidr_block" {
  description = "The CIDR block of public subnet 1."
  value       = module.vpc.public_subnet1_cidr_block
}

output "public_subnet1_availability_zone" {
  description = "The Availability Zone of public subnet 1."
  value       = module.vpc.public_subnet1_availability_zone
}

output "public_subnet2_id" {
  description = "The ID of public subnet 2."
  value       = module.vpc.public_subnet2_id
}

output "public_subnet2_arn" {
  description = "The ARN of public subnet 2."
  value       = module.vpc.public_subnet2_arn
}

output "public_subnet2_cidr_block" {
  description = "The CIDR block of public subnet 2."
  value       = module.vpc.public_subnet2_cidr_block
}

output "public_subnet2_availability_zone" {
  description = "The Availability Zone of public subnet 2."
  value       = module.vpc.public_subnet2_availability_zone
}

output "private_subnet1_id" {
  description = "The ID of private subnet 1."
  value       = module.vpc.public_subnet1_id
}

output "private_subnet1_arn" {
  description = "The ARN of private subnet 1."
  value       = module.vpc.private_subnet1_arn
}

output "private_subnet1_cidr_block" {
  description = "The CIDR block of private subnet 1."
  value       = module.vpc.private_subnet1_cidr_block
}

output "private_subnet1_availability_zone" {
  description = "The Availability Zone of private subnet 1."
  value       = module.vpc.private_subnet1_availability_zone
}

output "private_subnet2_id" {
  description = "The ID of private subnet 2."
  value       = module.vpc.private_subnet2_id
}

output "private_subnet2_arn" {
  description = "The ARN of private subnet 2."
  value       = module.vpc.private_subnet2_arn
}

output "private_subnet2_cidr_block" {
  description = "The CIDR block of private subnet 2."
  value       = module.vpc.private_subnet2_cidr_block
}

output "private_subnet2_availability_zone" {
  description = "The Availability Zone of private subnet 2."
  value       = module.vpc.private_subnet2_availability_zone
}

# List of all public subnet IDs
output "all_public_subnet_ids" {
  description = "A list of all public subnet IDs."
  value       = [module.vpc.public_subnet1_id, module.vpc.public_subnet2_id]
}

# List of all private subnet IDs
output "all_private_subnet_ids" {
  description = "A list of all private subnet IDs."
  value       = [module.vpc.private_subnet1_id, module.vpc.private_subnet2_id]
}

output "jump_box_id" {
  value = module.ec2.jump_box_id
}

output "jump_box_public_ip" {
  value = module.ec2.jump_box_public_ip
}

# --- Internet Gateway Outputs ---
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = module.vpc.internet_gateway_id
}

# --- NAT Gateway and EIP Outputs ---
output "nat_gateway_eip_public_ip" {
  description = "The public IP address of the Elastic IP used by the NAT Gateway."
  value       = module.vpc.nat_gateway_eip_public_ip
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway."
  value       = module.vpc.nat_gateway_id
}

output "nat_gateway_public_subnet_id" {
  description = "The ID of the public subnet where the NAT Gateway resides."
  value       = module.vpc.nat_gateway_public_subnet_id # This is the aws_subnet.public1.id
}

# --- Route Table Outputs ---
output "public_route_table_id" {
  description = "The ID of the public route table."
  value       = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  description = "The ID of the private route table."
  value       = module.vpc.private_route_table_id
}
output "k8s_node1_id" {
  value = module.ec2.k8s_node1_id
}

output "k8s_node2_id" {
  value = module.ec2.k8s_node2_id
}

output "nlb_dns_name" {
  value = module.load_balancer.nlb_dns_name
}

output "nlb_zone_id" {
  value = module.load_balancer.nlb_zone_id
}
output "sg1_id" {
  value = module.sg.sg1_id
}

output "sg2_id" {
  value = module.sg.sg2_id
}
output "k8s_node1_private_ip" {
  value = module.ec2.k8s_node1_private_ip
}
output "k8s_node2_private_ip" {
  value = module.ec2.k8s_node2_private_ip
}
