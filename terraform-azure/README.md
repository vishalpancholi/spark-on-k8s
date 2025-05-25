# Terraform Infrastructure for Spark on AKS

This repository provides a modular Terraform setup to deploy Apache Spark on Azure Kubernetes Service (AKS), along with supporting infrastructure such as Azure Blob Storage and a MySQL database for Hive Metastore.

## Structure

```
terraform-azure/
├── main.tf              # Root configuration that calls module blocks
├── variables.tf         # Input variable definitions
├── outputs.tf           # Output values
├── provider.tf          # Azure provider configuration
├── versions.tf          # Terraform and provider version constraints
├── terraform.tfvars     # Variable values (azure_subscription_id, mysql_admin_password)
├── modules/
│   ├── aks/             # AKS cluster module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── mysql/           # MySQL database module for Hive Metastore
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── storage/         # Azure Blob Storage module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md            # Documentation
```

## Modules

- **AKS**: Provisions an Azure Kubernetes Service cluster with a system-managed node pool and an additional node pool for spark.
- **MySQL**: Deploys a MySQL database used as the Hive Metastore backend.
- **Storage**: Creates Azure Blob Storage containers for raw and processed data.

## Prerequisites

Make sure the following tools are installed on your system:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.3
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.45
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (for managing the AKS cluster)

Login and configure your Azure environment:

```bash
az login
az account set --subscription "<your-subscription-name-or-id>"
```

## Usage

To deploy the infrastructure:

1. Navigate to the desired environment directory:
   ```
   cd terraform-azure/
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

5. To connect to the AKS cluster after deployment:
   ```
   az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
   ```

## Configuration

All configurations are managed through variables defined in `variables.tf` and subscription_id and mysql password in `terraform.tfvars`. Modify these files to adjust the infrastructure to your needs.
