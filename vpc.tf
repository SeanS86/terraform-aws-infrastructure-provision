module "vpc" {
  source = "./modules/vpc"

  project_name  = var.project

  vpc_cidr                  = var.vpc_cidr
  public_subnet1_cidr       = var.public_subnet1_cidr
  public_subnet2_cidr       = var.public_subnet2_cidr
  private_subnet1_cidr      = var.private_subnet1_cidr
  private_subnet2_cidr      = var.public_subnet2_cidr
  availability_zone1        = var.availability_zone1
  availability_zone2        = var.availability_zone2

}
