# --- VPC Outputs ---
output "vpc_id" {
  description = "The ID of the main VPC."
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "The ARN of the main VPC."
  value       = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  description = "The primary CIDR block of the main VPC."
  value       = aws_vpc.main.cidr_block
}

output "vpc_default_route_table_id" {
  description = "The ID of the main VPC's default route table."
  value       = aws_vpc.main.default_route_table_id
}

output "vpc_default_network_acl_id" {
  description = "The ID of the main VPC's default network ACL."
  value       = aws_vpc.main.default_network_acl_id
}

output "vpc_default_security_group_id" {
  description = "The ID of the main VPC's default security group."
  value       = aws_vpc.main.default_security_group_id
}

# --- Subnet Outputs ---
output "public_subnet1_id" {
  description = "The ID of public subnet 1."
  value       = aws_subnet.public1.id
}

output "public_subnet1_arn" {
  description = "The ARN of public subnet 1."
  value       = aws_subnet.public1.arn
}

output "public_subnet1_cidr_block" {
  description = "The CIDR block of public subnet 1."
  value       = aws_subnet.public1.cidr_block
}

output "public_subnet1_availability_zone" {
  description = "The Availability Zone of public subnet 1."
  value       = aws_subnet.public1.availability_zone
}

output "public_subnet2_id" {
  description = "The ID of public subnet 2."
  value       = aws_subnet.public2.id
}

output "public_subnet2_arn" {
  description = "The ARN of public subnet 2."
  value       = aws_subnet.public2.arn
}

output "public_subnet2_cidr_block" {
  description = "The CIDR block of public subnet 2."
  value       = aws_subnet.public2.cidr_block
}

output "public_subnet2_availability_zone" {
  description = "The Availability Zone of public subnet 2."
  value       = aws_subnet.public2.availability_zone
}

output "private_subnet1_id" {
  description = "The ID of private subnet 1."
  value       = aws_subnet.private1.id
}

output "private_subnet1_arn" {
  description = "The ARN of private subnet 1."
  value       = aws_subnet.private1.arn
}

output "private_subnet1_cidr_block" {
  description = "The CIDR block of private subnet 1."
  value       = aws_subnet.private1.cidr_block
}

output "private_subnet1_availability_zone" {
  description = "The Availability Zone of private subnet 1."
  value       = aws_subnet.private1.availability_zone
}

output "private_subnet2_id" {
  description = "The ID of private subnet 2."
  value       = aws_subnet.private2.id
}

output "private_subnet2_arn" {
  description = "The ARN of private subnet 2."
  value       = aws_subnet.private2.arn
}

output "private_subnet2_cidr_block" {
  description = "The CIDR block of private subnet 2."
  value       = aws_subnet.private2.cidr_block
}

output "private_subnet2_availability_zone" {
  description = "The Availability Zone of private subnet 2."
  value       = aws_subnet.private2.availability_zone
}

# List of all public subnet IDs
output "all_public_subnet_ids" {
  description = "A list of all public subnet IDs."
  value       = [aws_subnet.public1.id, aws_subnet.public2.id]
}

# List of all private subnet IDs
output "all_private_subnet_ids" {
  description = "A list of all private subnet IDs."
  value       = [aws_subnet.private1.id, aws_subnet.private2.id]
}

# --- Internet Gateway Outputs ---
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.igw.id
}

# --- NAT Gateway and EIP Outputs ---
output "nat_gateway_eip_public_ip" {
  description = "The public IP address of the Elastic IP used by the NAT Gateway."
  value       = aws_eip.nat.public_ip
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway."
  value       = aws_nat_gateway.nat.id
}

output "nat_gateway_public_subnet_id" {
  description = "The ID of the public subnet where the NAT Gateway resides."
  value       = aws_nat_gateway.nat.subnet_id # This is the aws_subnet.public1.id
}

# --- Route Table Outputs ---
output "public_route_table_id" {
  description = "The ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the private route table."
  value       = aws_route_table.private.id
}

