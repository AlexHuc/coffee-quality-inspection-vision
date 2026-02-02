# Artifact Registry Repository for Docker images
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.gcp_region
  repository_id = var.app_name
  description   = "Docker repository for ${var.app_name}"
  format        = "DOCKER"
  cleanup_policy {
    condition {
      tag_state             = "ANY"
      tag_count_newer       = 10
      older_than_days       = null
    }
    action = "DELETE"
  }

  labels = local.labels
}

# Grant Artifact Registry access to service account
resource "google_artifact_registry_repository_iam_member" "docker_reader" {
  location   = google_artifact_registry_repository.docker_repo.location
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Grant push permissions to Artifact Registry
resource "google_artifact_registry_repository_iam_member" "docker_writer" {
  location   = google_artifact_registry_repository.docker_repo.location
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.writer"
  member     = "principalSet://goog/cloud-build-service-accounts"
}
