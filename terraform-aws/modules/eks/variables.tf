variable "name_prefix" {
    description = "Prefix to be used for resource naming"
    type        = string
  }
  
  variable "eks_cluster_version" {
    description = "Kubernetes version for the EKS cluster"
    type        = string
  }
  
  variable "vpc_id" {
    description = "ID of the VPC"
    type        = string
  }
  
  variable "subnet_ids" {
    description = "List of subnet IDs for the EKS cluster"
    type        = list(string)
  }
  
  variable "node_instance_types" {
    description = "EC2 instance types for EKS node groups"
    type        = list(string)
  }
  
  variable "node_min_size" {
    description = "Minimum number of worker nodes"
    type        = number
  }
  
  variable "node_max_size" {
    description = "Maximum number of worker nodes"
    type        = number
  }
  
  variable "node_desired_size" {
    description = "Desired number of worker nodes"
    type        = number
  }
  
  variable "s3_bucket_raw_arn" {
    description = "ARN of the S3 bucket for raw data"
    type        = string
  }
  
  variable "s3_bucket_transformed_arn" {
    description = "ARN of the S3 bucket for transformed data"
    type        = string
  }
  
  variable "tags" {
    description = "Tags to apply to all resources"
    type        = map(string)
    default     = {}
  }