# Cloud Run Service (v2 API)
resource "google_cloud_run_v2_service" "api" {
  name     = var.app_name
  location = var.gcp_region
  
  deletion_protection = false
  ingress             = var.enable_public_access ? "INGRESS_TRAFFIC_ALL" : "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    service_account = google_service_account.cloud_run.email

    max_instance_request_concurrency = var.concurrency
    timeout                          = "${var.container_timeout}s"

    containers {
      image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${local.image_name}:${var.container_image_tag}"

      ports {
        container_port = var.container_port
      }

      resources {
        limits = {
          cpu    = var.container_cpu
          memory = var.container_memory
        }
      }

      env {
        name  = "FLASK_ENV"
        value = var.environment
      }

      startup_probe {
        initial_delay_seconds = 0
        timeout_seconds       = 300
        period_seconds        = 240
        failure_threshold     = 1
        http_get {
          path = "/health"
          port = var.container_port
        }
      }

      liveness_probe {
        initial_delay_seconds = 0
        timeout_seconds       = 5
        period_seconds        = 30
        failure_threshold     = 3
        http_get {
          path = "/health"
          port = var.container_port
        }
      }
    }

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    vpc_access {
      connector = var.enable_vpc_connector ? var.vpc_connector_name : null
      egress    = var.enable_vpc_connector ? "PRIVATE_RANGES_ONLY" : "ALL_TRAFFIC"
    }

    session_affinity = false
  }

  labels = local.labels

  depends_on = [
    google_artifact_registry_repository.docker_repo
  ]
}

# Service IAM Binding for public access
resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  count    = var.enable_public_access ? 1 : 0
  location = google_cloud_run_v2_service.api.location
  service  = google_cloud_run_v2_service.api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Cloud Run Traffic Splitting (for gradual rollouts)
# Uncomment to enable traffic splitting between revisions
# resource "google_cloud_run_service_traffic" "traffic_split" {
#   location = google_cloud_run_v2_service.api.location
#   service  = google_cloud_run_v2_service.api.name
#
#   traffic {
#     percent         = 80
#     revision_name   = google_cloud_run_v2_service.api.latest_created_revision
#     latest_revision = true
#   }
# }
