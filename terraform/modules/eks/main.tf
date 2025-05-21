# Get the current AWS caller identity
data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.name_prefix}-eks"
  cluster_version = var.eks_cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.subnet_ids

  # EKS managed node groups
  eks_managed_node_groups = {
    workers = {
      name = "workers"

      instance_types = var.node_instance_types

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      # Minimal disk size for free tier
      disk_size = 20
    }
  }

  # Enable EKS managed add-ons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # Enable public access to the Kubernetes API server
  cluster_endpoint_public_access = true

  # Restrict access to specific IP addresses if needed
  # cluster_endpoint_public_access_cidrs = ["YOUR_IP_ADDRESS/32"]

  # AWS auth configuration
  access_entries = {
    # Add your current IAM user/role for admin access
    default = {
      kubernetes_groups = []
      principal_arn     = data.aws_caller_identity.current.arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = var.tags
}

# Create IAM policy for EKS nodes to access S3
resource "aws_iam_policy" "s3_access" {
  name        = "${var.name_prefix}-s3-access"
  description = "Policy allowing EKS nodes to access S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          var.s3_bucket_raw_arn,
          "${var.s3_bucket_raw_arn}/*",
          var.s3_bucket_transformed_arn,
          "${var.s3_bucket_transformed_arn}/*"
        ]
      }
    ]
  })
}

# Attach the S3 access policy to the EKS node group role
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = module.eks.eks_managed_node_groups["workers"].iam_role_name
  policy_arn = aws_iam_policy.s3_access.arn
}