# Terraform Infrastructure for Spark on EKS

This repository contains a modular Terraform infrastructure for deploying Apache Spark on Amazon EKS.

## Structure

```
terraform/
├── envs/                  # Environment-specific configurations
│   └── dev/               # Development environment
│       ├── main.tf        # Main configuration
│       ├── variables.tf   # Input variables
│       ├── terraform.tfvars # Variable values
│       ├── outputs.tf     # Output values
│       └── backend.tf     # State backend configuration
├── modules/               # Reusable infrastructure modules
│   ├── vpc/               # VPC networking module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eks/               # EKS cluster module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── s3/                # S3 storage buckets module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/               # RDS database module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── security/          # Security configurations module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md              # Documentation
```

## Modules

- **VPC**: Creates a VPC with public, private, and database subnets
- **EKS**: Provisions an EKS cluster with a managed node group
- **S3**: Creates buckets for raw and transformed data storage
- **RDS**: Sets up a MySQL database for Hive Metastore
- **Security**: Manages security group rules between components (e.g., EKS to RDS connectivity)

## Usage

To deploy the infrastructure:

1. Navigate to the desired environment directory:
   ```
   cd terraform/envs/dev
   ```

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Plan the deployment:
   ```
   terraform plan
   ```

4. Apply the configuration:
   ```
   terraform apply
   ```

5. To connect to the EKS cluster after deployment:
   ```
   aws eks update-kubeconfig --name <cluster-name> --region <region>
   ```

## Configuration

All configurations are managed through variables defined in `variables.tf` and set in `terraform.tfvars`. Modify these files to adjust the infrastructure to your needs.
