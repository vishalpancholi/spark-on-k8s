variable "aws_region" {
    description = "AWS region to deploy resources"
    type        = string
    default     = "us-east-1"  # Choose a region with good Free Tier coverage
  }

  variable "environment" {
    description = "Environment name (e.g., dev, staging, prod)"
    type        = string
    default     = "dev"
  }

  variable "project_name" {
    description = "Project name used for resource naming"
    type        = string
    default     = "spark"
  }

  # VPC and Networking
  variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
  }

  variable "availability_zones" {
    description = "List of availability zones to use"
    type        = list(string)
    default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }

  # EKS
  variable "eks_cluster_version" {
    description = "Kubernetes version for the EKS cluster"
    type        = string
    default     = "1.32"  # Choose the latest version supported by your tools
  }

  variable "node_instance_types" {
    description = "EC2 instance types for EKS node groups"
    type        = list(string)
    default     = ["t2.micro"]  # Free tier compatible
  }

  variable "node_desired_size" {
    description = "Desired number of worker nodes"
    type        = number
    default     = 1  # Reduced for cost savings, minimum for Spark master and one worker
  }

  variable "node_min_size" {
    description = "Minimum number of worker nodes"
    type        = number
    default     = 1
  }

  variable "node_max_size" {
    description = "Maximum number of worker nodes"
    type        = number
    default     = 7
  }

  # S3
  variable "data_bucket_name" {
    description = "Name of S3 bucket to store raw and processed data"
    type        = string
    default     = null  # Will be dynamically generated if not provided
  }

  # RDS (Hive Metastore Backend)
  variable "db_instance_class" {
    description = "RDS instance class for Hive Metastore database"
    type        = string
    default     = "db.t4g.micro"  # Free tier eligible ARM-based instance
  }

  variable "db_name" {
    description = "Database name for Hive Metastore"
    type        = string
    default     = "hivemetastore"
  }

  variable "db_username" {
    description = "Username for database access"
    type        = string
    default     = "hiveuser"
    sensitive   = true
  }

  variable "db_password" {
    description = "Password for database access"
    type        = string
    sensitive   = true
  }
