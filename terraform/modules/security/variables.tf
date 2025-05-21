variable "eks_node_security_group_id" {
    description = "Security group ID of the EKS nodes"
    type        = string
  }
  
  variable "rds_security_group_id" {
    description = "Security group ID of the RDS instance"
    type        = string
  }