terraform {
  backend "s3" {
    region       = "eu-west-1"
    bucket       = "723307514167-assesment-tf-state"
    key          = "terraform.tfstate"
  }
}

provider "aws" {
  region         = "eu-west-1"
}