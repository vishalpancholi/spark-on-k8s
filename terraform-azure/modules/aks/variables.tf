// Defines input variables for the AKS module.
variable "resource_group_name" {
  description = "Name of the Azure Resource Group where AKS will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS default node pool."
  type        = number
}

variable "aks_node_vm_size" {
  description = "VM size for AKS worker nodes."
  type        = string
}

variable "aks_subnet_id" {
  description = "The ID of the subnet where AKS nodes will be deployed."
  type        = string
}

variable "aks_default_nodepool_enable_auto_scaling" {
  description = "Enable autoscaling for the default node pool."
  type        = bool
}

variable "aks_default_nodepool_min_count" {
  description = "Minimum number of nodes for the default node pool when autoscaling is enabled."
  type        = number
}

variable "aks_default_nodepool_max_count" {
  description = "Maximum number of nodes for the default node pool when autoscaling is enabled."
  type        = number
}