module "vpc" {
  source = "./modules/vpc"

  cloud_region  = var.region

  project_name  = var.project

}
