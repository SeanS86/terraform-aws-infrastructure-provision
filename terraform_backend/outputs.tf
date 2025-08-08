
output "s3_bucket_id" {
  description = "The ID (name) of the S3 bucket created for Terraform state."
  value       = aws_s3_bucket.terraform_state.id
}