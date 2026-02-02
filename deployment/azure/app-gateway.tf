# Virtual Network for Application Gateway
resource "azurerm_virtual_network" "main" {
  name                = "${var.app_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.tags
}

# Subnet for Application Gateway
resource "azurerm_subnet" "gateway" {
  name                 = "gateway-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "app_gateway" {
  count               = var.enable_app_gateway ? 1 : 0
  name                = "${var.app_name}-appgw-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  count               = var.enable_app_gateway ? 1 : 0
  name                = "${var.app_name}-appgw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = var.app_gateway_capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.gateway.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.app_gateway[0].id
  }

  backend_address_pool {
    name = "backend-pool"

    dynamic "fqdns" {
      for_each = var.deployment_type == "app-service" ? [azurerm_linux_web_app.main[0].default_hostname] : (var.deployment_type == "container-instances" ? [azurerm_container_group.main[0].fqdn] : [])
      content {
        fqdn = fqdns.value
      }
    }
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = var.container_port
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "http-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 100
  }

  tags = local.tags

  depends_on = [
    azurerm_linux_web_app.main,
    azurerm_container_group.main
  ]
}
