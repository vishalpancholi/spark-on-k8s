// Defines output values for the AKS module.
output "aks_cluster_id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_kube_config_raw" {
  description = "Raw Kubernetes config for the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "principal_id" {
  description = "The principal ID of the AKS cluster's system-assigned managed identity"
  value       = azurerm_kubernetes_cluster.main.identity[0].principal_id
}