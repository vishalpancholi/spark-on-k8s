module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr

  # Use only 2 AZs to reduce costs
  azs             = [var.availability_zones[0], var.availability_zones[1]]
  private_subnets = [cidrsubnet(var.vpc_cidr, 4, 0), cidrsubnet(var.vpc_cidr, 4, 1)]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 4, 2), cidrsubnet(var.vpc_cidr, 4, 3)]
  database_subnets = [cidrsubnet(var.vpc_cidr, 4, 4), cidrsubnet(var.vpc_cidr, 4, 5)]

  create_database_subnet_group = true
  enable_nat_gateway     = true
  single_nat_gateway     = true  # To reduce costs
  enable_dns_hostnames   = true
  enable_dns_support     = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "shared"
    "kubernetes.io/role/elb"                         = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "shared"
    "kubernetes.io/role/internal-elb"                = "1"
  }

  tags = var.tags
}

# Security group for RDS
module "security_group_rds" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = "${var.name_prefix}-rds-sg"
  description = "Security group for HMS RDS instance"
  vpc_id      = module.vpc.vpc_id

  # Only define egress rules here
  # Ingress rules will be added by the security module after EKS is created
  egress_rules = ["all-all"]

  tags = var.tags
}