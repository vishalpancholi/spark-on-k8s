# Simple S3 bucket for raw data
resource "aws_s3_bucket" "raw" {
  bucket = "${var.data_bucket_name}-raw"
  tags   = var.tags
}

# Simple S3 bucket for transformed data
resource "aws_s3_bucket" "transformed" {
  bucket = "${var.data_bucket_name}-transformed"
  tags   = var.tags
}

# Block public access for both buckets
resource "aws_s3_bucket_public_access_block" "raw" {
  bucket                  = aws_s3_bucket.raw.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "transformed" {
  bucket                  = aws_s3_bucket.transformed.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}