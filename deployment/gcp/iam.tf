# Service Account for Cloud Run
resource "google_service_account" "cloud_run" {
  account_id   = "${var.app_name}-sa"
  display_name = "Service Account for ${var.app_name}"
  description  = "Service account used by Cloud Run to execute ${var.app_name}"
}

# Role: Cloud Run Service Agent
resource "google_project_iam_member" "cloud_run_service_agent" {
  project = var.gcp_project_id
  role    = "roles/run.serviceAgent"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Role: Artifact Registry Reader (to pull Docker images)
resource "google_project_iam_member" "artifact_registry_reader" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Role: Cloud Logging Log Writer
resource "google_project_iam_member" "logging_log_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Role: Cloud Monitoring Metric Writer
resource "google_project_iam_member" "monitoring_metric_writer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Optional: Cloud Storage access for models
resource "google_project_iam_member" "storage_object_viewer" {
  count   = var.enable_model_bucket ? 1 : 0
  project = var.gcp_project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Policy Data for public access
resource "google_cloud_run_service_iam_policy" "public_access" {
  count       = var.enable_public_access ? 1 : 0
  location    = google_cloud_run_v2_service.api.location
  service     = google_cloud_run_v2_service.api.name
  policy_data = data.google_iam_policy.public_access[0].policy_data
}

data "google_iam_policy" "public_access" {
  count = var.enable_public_access ? 1 : 0
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers"
    ]
  }
}

# Optional: Service account key for local development
# resource "google_service_account_key" "cloud_run_key" {
#   service_account_id = google_service_account.cloud_run.name
#   public_key_type    = "TYPE_X509_PEM_FILE"
# }
