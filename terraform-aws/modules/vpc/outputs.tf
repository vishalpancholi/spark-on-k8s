output "vpc_id" {
    description = "ID of the VPC"
    value       = module.vpc.vpc_id
  }
  
  output "private_subnets" {
    description = "List of private subnet IDs"
    value       = module.vpc.private_subnets
  }
  
  output "public_subnets" {
    description = "List of public subnet IDs"
    value       = module.vpc.public_subnets
  }
  
  output "database_subnets" {
    description = "List of database subnet IDs"
    value       = module.vpc.database_subnets
  }
  
  output "database_subnet_group_name" {
    description = "Name of the database subnet group"
    value       = module.vpc.database_subnet_group_name
  }
  
  output "security_group_rds_id" {
    description = "ID of the RDS security group"
    value       = module.security_group_rds.security_group_id
  }