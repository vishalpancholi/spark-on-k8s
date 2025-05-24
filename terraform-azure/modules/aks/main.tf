// Defines the Azure Kubernetes Service (AKS) cluster.
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.aks_cluster_name}-dns"

  default_node_pool {
    name              = "default"
    node_count        = var.aks_node_count
    vm_size           = var.aks_node_vm_size
    vnet_subnet_id    = var.aks_subnet_id
    enable_auto_scaling = var.aks_default_nodepool_enable_auto_scaling
    min_count           = var.aks_default_nodepool_min_count
    max_count           = var.aks_default_nodepool_max_count
  }

  identity {
    type = "SystemAssigned" 
  }

  tags = {
    environment = "dev"
    project     = "granica-demo"
  }
}