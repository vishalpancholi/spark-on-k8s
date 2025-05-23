output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "s3_bucket_raw_name" {
    description = "Name of the S3 bucket for raw data"
    value       = module.s3.s3_bucket_raw_id
  }
  
  output "s3_bucket_transformed_name" {
    description = "Name of the S3 bucket for transformed data"
    value       = module.s3.s3_bucket_transformed_id
  }
  
  output "rds_hostname" {
    description = "RDS instance hostname"
    value       = module.rds.db_instance_address
  }
  
  output "rds_port" {
    description = "RDS instance port"
    value       = module.rds.db_instance_port
  }
  
  output "rds_username" {
    description = "RDS instance root username"
    value       = module.rds.db_instance_username
    sensitive   = true
  }
  
  output "rds_password" {
    description = "RDS instance root password"
    value       = var.db_password
    sensitive   = true
  }
  
  output "aws_region" {
    description = "AWS region where resources are deployed"
    value       = var.aws_region
  }
  
  output "configure_kubectl" {
    description = "Command to configure kubectl to connect to the EKS cluster"
    value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
  }
  
  output "spark_master_port_forward" {
    description = "Command to port forward the Spark master UI"
    value       = "kubectl port-forward -n spark svc/spark-master 8080:8080"
  }