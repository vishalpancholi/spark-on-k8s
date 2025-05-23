// main.tf
// Main configuration file for the root module.
// Creates a resource group and calls the modules for AKS, MySQL, and Storage.

// Create an Azure Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.aks_cluster_name}-vnet"
  address_space       = ["192.168.0.0/17"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

// Create a Subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.aks_cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["192.168.0.0/20"]
}

// Create a Subnet for MySQL (separate subnet for database isolation)
resource "azurerm_subnet" "mysql_subnet" {
  name                 = "${var.mysql_server_name}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["192.168.16.0/21"]

  # Required for MySQL Flexible Server
  delegation {
    name = "mysql-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_role_assignment" "aks_storage_blob_contributor" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.aks.principal_id
}

// Call the AKS module
module "aks" {
  source              = "./modules/aks" // Path to the AKS module
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  aks_cluster_name    = var.aks_cluster_name
  aks_node_count      = var.aks_node_count
  aks_node_vm_size    = var.aks_node_vm_size
  aks_subnet_id       = azurerm_subnet.aks_subnet.id
}

// Call the MySQL module
module "mysql" {
  source               = "./modules/mysql" // Path to the MySQL module
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  mysql_server_name    = var.mysql_server_name
  mysql_admin_username = var.mysql_admin_username
  mysql_admin_password = var.mysql_admin_password
  mysql_database_name  = var.mysql_database_name
  mysql_subnet_id      = azurerm_subnet.mysql_subnet.id
  #   mysql_private_dns_zone_id = azurerm_private_dns_zone.mysql_dns.id

  #   depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_dns_link]
}

// Call the Storage module
module "storage" {
  source                 = "./modules/storage" // Path to the Storage module
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  storage_account_name   = var.storage_account_name
  storage_container_name = var.storage_container_name
}
