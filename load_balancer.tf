module "load_balancer" {
  source = "./modules/load_balancer"

  project_name  = var.project

  public_subnet1_id = module.vpc.public_subnet1_id
  public_subnet2_id = module.vpc.public_subnet2_id
  vpc_id            = module.vpc.vpc_id
  k8s_node1_id      = module.ec2.k8s_node1_id
  k8s_node2_id      = module.ec2.k8s_node2_id

  dashboard_node_port = var.dashboard_node_port
}
