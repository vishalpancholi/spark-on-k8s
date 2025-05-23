// Defines output values for the MySQL module.
output "mysql_server_fqdn" {
  description = "The fully qualified domain name of the MySQL server."
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "mysql_server_name" {
  description = "The name of the MySQL server."
  value       = azurerm_mysql_flexible_server.main.name
}

output "mysql_database_name" {
  description = "The name of the created database."
  value       = azurerm_mysql_flexible_database.main.name
}

output "mysql_admin_username" {
  description = "The administrator username for the MySQL server."
  value       = azurerm_mysql_flexible_server.main.administrator_login
}

output "mysql_connection_string" {
  description = "Connection string for the MySQL database (without password)."
  value       = "Server=${azurerm_mysql_flexible_server.main.fqdn};Database=${azurerm_mysql_flexible_database.main.name};Uid=${azurerm_mysql_flexible_server.main.administrator_login};"
  sensitive   = false
}