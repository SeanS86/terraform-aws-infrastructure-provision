
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "Terraform State Storage"
    Environment = "Backend"
    ManagedBy   = "Terraform"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "Backend"
    ManagedBy   = "Terraform"
  }
}