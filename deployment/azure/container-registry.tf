# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = replace("${var.app_name}reg", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.container_registry_sku
  admin_enabled       = true

  tags = local.tags
}

# Container Registry Role Assignment for App Service (if deployed)
resource "azurerm_role_assignment" "acr_pull_app_service" {
  count              = var.deployment_type == "app-service" ? 1 : 0
  scope              = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id       = try(azurerm_linux_web_app.main[0].identity[0].principal_id, null)
}

# Container Registry Role Assignment for Container Group (if deployed)
resource "azurerm_role_assignment" "acr_pull_container_group" {
  count              = var.deployment_type == "container-instances" ? 1 : 0
  scope              = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id       = try(azurerm_user_assigned_identity.container_group[0].principal_id, null)
}
