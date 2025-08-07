
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

variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "eu-west-1"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state. Must be globally unique."
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking."
  type        = string
  default     = "terraform-state-lock"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name

  # Block public access to the bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

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

output "s3_bucket_id" {
  description = "The ID (name) of the S3 bucket created for Terraform state."
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name_output" {
  description = "The name of the DynamoDB table created for state locking."
  value       = aws_dynamodb_table.terraform_locks.name
}
