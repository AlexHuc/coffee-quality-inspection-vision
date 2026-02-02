# Main Terraform configuration for Coffee Prediction API on AWS

locals {
  container_name = "${var.app_name}-container"
  service_name   = "${var.app_name}-service"
  cluster_name   = "${var.app_name}-cluster"
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get current AWS region
data "aws_region" "current" {}
