# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = replace("${var.app_name}storage", "-", "")
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

# Storage Container for Models
resource "azurerm_storage_container" "models" {
  count                 = var.enable_blob_storage ? 1 : 0
  name                  = "models"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Storage Container for Logs
resource "azurerm_storage_container" "logs" {
  name                  = "logs"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
