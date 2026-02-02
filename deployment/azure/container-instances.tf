# Container Group (for Container Instances deployment)
resource "azurerm_container_group" "main" {
  count               = var.deployment_type == "container-instances" ? 1 : 0
  name                = "${var.app_name}-container-group"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = var.app_name
  restart_policy      = var.restart_policy

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_group[0].id]
  }

  dynamic "container" {
    for_each = range(var.container_instances_count)
    content {
      name   = "${var.app_name}-container-${container.value + 1}"
      image  = "${azurerm_container_registry.main.login_server}/${var.app_name}:${var.container_image_tag}"
      cpu    = var.container_cpu
      memory = var.container_memory

      ports {
        port     = var.container_port
        protocol = "TCP"
      }

      environment_variables = {
        FLASK_ENV = var.environment
      }
    }
  }

  image_registry_credential {
    server   = azurerm_container_registry.main.login_server
    username = azurerm_container_registry.main.admin_username
    password = azurerm_container_registry.main.admin_password
  }

  depends_on = [
    azurerm_role_assignment.acr_pull_container_group
  ]

  tags = local.tags
}
