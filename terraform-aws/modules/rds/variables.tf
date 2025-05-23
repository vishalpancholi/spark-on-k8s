variable "name_prefix" {
    description = "Prefix to be used for resource naming"
    type        = string
  }

  variable "db_instance_class" {
    description = "RDS instance class for Hive Metastore database"
    type        = string
  }

  variable "db_name" {
    description = "Database name for Hive Metastore"
    type        = string
  }
  
  variable "db_username" {
    description = "Username for database access"
    type        = string
    sensitive   = true
  }

  variable "db_password" {
    description = "Password for database access"
    type        = string
    sensitive   = true
  }

  variable "db_subnet_group_name" {
    description = "Name of the DB subnet group"
    type        = string
  }

  variable "rds_security_group_id" {
    description = "ID of the security group for RDS"
    type        = string
  }

  variable "tags" {
    description = "Tags to apply to all resources"
    type        = map(string)
    default     = {}
  }