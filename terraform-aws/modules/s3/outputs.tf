output "s3_bucket_raw_id" {
    description = "ID of the S3 bucket for raw data"
    value       = aws_s3_bucket.raw.id
  }
  
  output "s3_bucket_transformed_id" {
    description = "ID of the S3 bucket for transformed data"
    value       = aws_s3_bucket.transformed.id
  }
  
  output "s3_bucket_raw_arn" {
    description = "ARN of the S3 bucket for raw data"
    value       = aws_s3_bucket.raw.arn
  }
  
  output "s3_bucket_transformed_arn" {
    description = "ARN of the S3 bucket for transformed data"
    value       = aws_s3_bucket.transformed.arn
  }