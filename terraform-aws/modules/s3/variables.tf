variable "data_bucket_name" {
    description = "Name of S3 bucket to store raw and processed data"
    type        = string
  }
  
  variable "tags" {
    description = "Tags to apply to all resources"
    type        = map(string)
    default     = {}
  }