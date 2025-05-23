// Defines Azure MySQL Flexible Server and database.
// Create MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "main" {
  name                   = var.mysql_server_name
  resource_group_name    = var.resource_group_name
  location               = var.location

  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password

  backup_retention_days  = 7
  storage {
    size_gb = var.mysql_storage_gb
  }
  sku_name              = var.mysql_sku_name
  version               = "8.0.21"

  # Network configuration for private access, uncomment if you want mysql to access only within AKS
#   delegated_subnet_id = var.mysql_subnet_id

  tags = {
    environment = "dev"
    project     = "granica-demo"
  }

}

// Create a database within the MySQL server
resource "azurerm_mysql_flexible_database" "main" {
  name                = var.mysql_database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

// Create firewall rule to allow AKS subnet access
resource "azurerm_mysql_flexible_server_firewall_rule" "aks_access" {
  name                = "allow-aks-subnet"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = "192.168.0.0"   # Start of AKS subnet range
  end_ip_address      = "192.168.15.255" # End of AKS subnet range
}

// Optional: Create firewall rule for your local development (remove in production)
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_local" {
  name                = "allow-local-dev"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"

  # Note: This allows all IPs - only for development.
  # In production, specify your specific IP range
}