# Cloud Storage Bucket for model storage
resource "google_storage_bucket" "models" {
  count           = var.enable_model_bucket ? 1 : 0
  name            = "${data.google_project.current.project_id}-${var.app_name}-models"
  location        = var.gcp_region
  force_destroy   = false
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }
    action {
      type = "Delete"
    }
  }

  labels = local.labels
}

# Grant Cloud Run service account read access to model bucket
resource "google_storage_bucket_iam_member" "cloud_run_models_reader" {
  count  = var.enable_model_bucket ? 1 : 0
  bucket = google_storage_bucket.models[0].name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Optional: Create a default model folder marker
resource "google_storage_bucket_object" "models_folder" {
  count   = var.enable_model_bucket ? 1 : 0
  name    = "models/.keep"
  content = ""
  bucket  = google_storage_bucket.models[0].name
}

# Cloud Storage Bucket for application logs
resource "google_storage_bucket" "logs" {
  name            = "${data.google_project.current.project_id}-${var.app_name}-logs"
  location        = var.gcp_region
  force_destroy   = false
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }

  labels = local.labels
}
