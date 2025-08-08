output "jump_box_public_ip" {
  description = "The public IP address of the jump box EC2 instance."
  value       = module.ec2.jump_box_public_ip
  sensitive   = false
}

output "k8s_node1_private_ip" {
  description = "The private IP address of the first Kubernetes node."
  value       = module.ec2.k8s_node1_private_ip
}

output "nlb_dns_name" {
  description = "The DNS name of the Network Load Balancer."
  value       = module.load_balancer.nlb_dns_name
}

output "vpc_id" {
  description = "The ID of the provisioned VPC."
  value       = module.vpc.vpc_id
}
