module "ec2" {
  source = "./modules/ec2"

  project_name  = var.project

  ami_id               = var.ami_id
  instance_type        = "t3.medium"
  public_subnet_id     = module.vpc.public_subnet1_id
  private_subnet1_id    = module.vpc.private_subnet1_id
  private_subnet2_id   = module.vpc.private_subnet2_id
  sg1_id               = module.sg.sg1_id
  sg2_id               = module.sg.sg2_id
  key_name             = "my-ec2-keypair"

}
