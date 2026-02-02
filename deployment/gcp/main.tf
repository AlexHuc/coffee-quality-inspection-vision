# Main Terraform configuration for Coffee Prediction API on GCP

locals {
  service_name = var.app_name
  image_name   = "coffee-prediction"
  
  labels = merge(
    var.labels,
    {
      app         = var.app_name
      environment = var.environment
      terraform   = "true"
    }
  )
}

# Data source to get current GCP project
data "google_client_config" "current" {}

data "google_project" "current" {
  project_id = var.gcp_project_id
}
