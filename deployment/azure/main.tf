# Main Terraform configuration for Coffee Prediction API on Azure

locals {
  app_name = var.app_name
  
  tags = merge(
    var.tags,
    {
      app         = var.app_name
      environment = var.environment
      terraform   = "true"
    }
  )
}

# Data source to get current Azure context
data "azurerm_client_config" "current" {}
