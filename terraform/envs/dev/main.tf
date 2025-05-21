provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "SparkOnEKS"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# The Kubernetes provider will be configured after the EKS cluster is created
# enables Terraform to manage Kubernetes resources
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
  required_version = ">= 1.0"
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Use provided bucket name or create one with "granica" included
  data_bucket_name = var.data_bucket_name != null ? var.data_bucket_name : "${local.name_prefix}-granica-data"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = local.tags
}

# S3 Buckets Module
module "s3" {
  source = "../../modules/s3"

  data_bucket_name = local.data_bucket_name
  tags             = local.tags
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  name_prefix            = local.name_prefix
  eks_cluster_version    = var.eks_cluster_version
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnets
  node_instance_types    = var.node_instance_types
  node_min_size          = var.node_min_size
  node_max_size          = var.node_max_size
  node_desired_size      = var.node_desired_size
  s3_bucket_raw_arn      = module.s3.s3_bucket_raw_arn
  s3_bucket_transformed_arn = module.s3.s3_bucket_transformed_arn
  tags                   = local.tags

  depends_on = [module.vpc]
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  name_prefix          = local.name_prefix
  db_instance_class    = var.db_instance_class
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_subnet_group_name = module.vpc.database_subnet_group_name
  rds_security_group_id = module.vpc.security_group_rds_id
  tags                 = local.tags

  depends_on = [module.vpc]
}

# Security Module - Add this after both EKS and RDS are created
module "security" {
  source = "../../modules/security"

  eks_node_security_group_id = module.eks.node_security_group_id
  rds_security_group_id      = module.vpc.security_group_rds_id

  depends_on = [module.eks, module.rds]
}