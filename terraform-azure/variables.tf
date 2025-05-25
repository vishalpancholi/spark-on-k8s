// Defines input variables for the root module.
variable "azure_subscription_id" {
  description = "The Azure Subscription ID to deploy resources into."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group to create."
  type        = string
  default     = "granica-rg"
}

variable "location" {
  description = "Azure region where resources will be deployed."
  type        = string
  default     = "Central India" // for cheapest nodes
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "spark-aks"
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS default node pool. Keep low for free tier."
  type        = number
  default     = 1 // for free tier
}

variable "aks_node_vm_size" {
  description = "VM size for AKS worker nodes. Choose a free tier compatible size if possible."
  type        = string
  default     = "standard_b2pls_v2" // cheapest across regions (central india)
}

variable "aks_default_nodepool_enable_auto_scaling" {
  description = "Enable autoscaling for the default node pool."
  type        = bool
  default     = true
}

variable "aks_default_nodepool_min_count" {
  description = "Minimum number of nodes for the default node pool when autoscaling is enabled."
  type        = number
  default     = 1
}

variable "aks_default_nodepool_max_count" {
  description = "Maximum number of nodes for the default node pool when autoscaling is enabled."
  type        = number
  default     = 10
}

variable "aks_spark_nodepool_enable_auto_scaling" {
  description = "Enable autoscaling for the default node pool."
  type        = bool
  default     = true
}

variable "aks_spark_nodepool_min_count" {
  description = "Minimum number of nodes for the default node pool when autoscaling is enabled."
  type        = number
  default     = 1
}

variable "aks_spark_nodepool_max_count" {
  description = "Maximum number of nodes for the default node pool when autoscaling is enabled."
  type        = number
  default     = 10
}

variable "aks_spark_nodepool_mode" {
  description = "mode of node pool."
  type        = string
  default     = "User"
}

variable "aks_spark_nodepool_os" {
  description = "os of node pool."
  type        = string
  default     = "Linux"
}

variable "aks_spark_nodepool_sku" {
  description = "sku of node pool"
  type        = string
  default     = "standard_b2pls_v2"
}

variable "storage_account_name" {
  description = "Name of the Azure Storage Account."
  type        = string
  default     = "granicasa"
}

variable "container_definitions" {
  description = "A map of objects defining the storage containers to create within the storage account."
  type = map(object({
    name                  = string
    container_access_type = optional(string, "private")
  }))
  default = {
    # Using specific keys like "main_container", "raw_data", etc.
    # for internal Terraform referencing. The 'name' attribute is the actual Azure container name.
    main_container = {
      name                  = "mycontainer"
      container_access_type = "private"
    },
    raw_data = {
      name                  = "row"
      container_access_type = "private"
    },
    transformed_data = {
      name                  = "transformed"
      container_access_type = "private"
    },
    application_data = {
      name                  = "application"
      container_access_type = "private"
    }
  }
}

// MySQL variables
variable "mysql_server_name" {
  description = "Name of the MySQL Flexible Server."
  type        = string
  default     = "spark-hms-mysql-server"
}

variable "mysql_admin_username" {
  description = "Administrator username for the MySQL server."
  type        = string
  default     = "mysqladmin"
}

variable "mysql_admin_password" {
  description = "Administrator password for the MySQL server. Must be strong."
  type        = string
  sensitive   = true
}

variable "mysql_database_name" {
  description = "Name of the initial database to create in MySQL server."
  type        = string
  default     = "hivemetastore"
}

variable "mysql_sku_name" {
  description = "The SKU name for the MySQL server."
  type        = string
  default     = "B_Standard_B1ms" // Burstable tier for cost efficiency
}

variable "mysql_storage_gb" {
  description = "Storage size in GB for the MySQL server."
  type        = number
  default     = 20 // 20GB minimum for Flexible Server
}

variable "zone" {
  description = "mysql server zone"
  type = number
  default = 2
}