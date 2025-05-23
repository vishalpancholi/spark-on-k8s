variable "name_prefix" {
    description = "Prefix to be used for resource naming"
    type        = string
  }

  variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type        = string
  }

  variable "availability_zones" {
    description = "List of availability zones to use"
    type        = list(string)
  }

  variable "tags" {
    description = "Tags to apply to all resources"
    type        = map(string)
    default     = {}
  }

  variable "create_rds_security_group" {
    description = "Whether to create the RDS security group"
    type        = bool
    default     = true
  }