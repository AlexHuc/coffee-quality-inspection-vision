# User-assigned Identity for Container Group
resource "azurerm_user_assigned_identity" "container_group" {
  count               = var.deployment_type == "container-instances" ? 1 : 0
  name                = "${var.app_name}-container-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = local.tags
}

# Role Assignment: Container Group - Storage Account
resource "azurerm_role_assignment" "container_storage" {
  count              = var.deployment_type == "container-instances" ? 1 : 0
  scope              = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id       = azurerm_user_assigned_identity.container_group[0].principal_id
}

# App Service Identity
resource "azurerm_user_assigned_identity" "app_service" {
  count               = var.deployment_type == "app-service" ? 1 : 0
  name                = "${var.app_name}-app-service-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = local.tags
}

# Role Assignment: App Service - Storage Account
resource "azurerm_role_assignment" "app_service_storage" {
  count              = var.deployment_type == "app-service" ? 1 : 0
  scope              = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id       = azurerm_user_assigned_identity.app_service[0].principal_id
}
