output "db_instance_address" {
    description = "RDS instance hostname"
    value       = module.rds.db_instance_address
  }
  
  output "db_instance_port" {
    description = "RDS instance port"
    value       = module.rds.db_instance_port
  }
  
  output "db_instance_username" {
    description = "RDS instance root username"
    value       = module.rds.db_instance_username
    sensitive   = true
  }