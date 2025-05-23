// Defines output values for the root module.
output "resource_group_id" {
  description = "The ID of the created Resource Group."
  value       = azurerm_resource_group.main.id
}

output "aks_cluster_id" {
  description = "The ID of the AKS cluster."
  value       = module.aks.aks_cluster_id
}

output "aks_kube_config_raw" {
  description = "Raw Kubernetes config for the AKS cluster."
  value       = module.aks.aks_kube_config_raw
  sensitive   = true
}

output "storage_account_primary_access_key" {
  description = "The primary access key for the Storage Account."
  value       = module.storage.storage_account_primary_access_key
  sensitive   = true
}

output "storage_account_name" {
  description = "The name of the Storage Account."
  value       = module.storage.storage_account_name
}


output "mysql_server_fqdn" {
  description = "The fully qualified domain name of the MySQL server."
  value       = module.mysql.mysql_server_fqdn
}

output "mysql_database_name" {
  description = "The name of the created database."
  value       = module.mysql.mysql_database_name
}

output "mysql_admin_username" {
  description = "The administrator username for the MySQL server."
  value       = module.mysql.mysql_admin_username
}

output "mysql_connection_info" {
  description = "MySQL connection information."
  value = {
    server   = module.mysql.mysql_server_fqdn
    database = module.mysql.mysql_database_name
    username = module.mysql.mysql_admin_username
  }
}
