variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "eu-west-1"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state. Must be globally unique."
  type        = string
}

