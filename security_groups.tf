module "sg" {
  source = "./modules/security_groups"

  project_name  = var.project

  vpc_id        = module.vpc.vpc_id
  vpc_cidr      = module.vpc.vpc_cidr_block

  tools_ec2_ip  = var.tools_ec2_ip

  dashboard_node_port = var.dashboard_node_port
}
