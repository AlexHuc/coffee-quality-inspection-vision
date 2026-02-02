output "cloud_run_service_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.api.uri
}

output "cloud_run_service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.api.name
}

output "artifact_registry_repository_url" {
  description = "URL of the Artifact Registry repository"
  value       = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}

output "artifact_registry_repository_name" {
  description = "Name of the Artifact Registry repository"
  value       = google_artifact_registry_repository.docker_repo.name
}

output "service_account_email" {
  description = "Email of the service account"
  value       = google_service_account.cloud_run.email
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.gcp_project_id
}

output "region" {
  description = "GCP Region"
  value       = var.gcp_region
}

output "health_check_url" {
  description = "Health check endpoint URL"
  value       = "${google_cloud_run_v2_service.api.uri}/health"
}

output "predict_endpoint" {
  description = "Prediction endpoint URL"
  value       = "${google_cloud_run_v2_service.api.uri}/predict"
}

output "model_bucket_name" {
  description = "Name of the model storage bucket"
  value       = try(google_storage_bucket.models[0].name, null)
}

output "model_bucket_url" {
  description = "URL of the model storage bucket"
  value       = try("gs://${google_storage_bucket.models[0].name}", null)
}

output "logs_sink_name" {
  description = "Name of the Cloud Logging sink"
  value       = try(google_logging_project_sink.cloud_run[0].name, null)
}

output "monitoring_dashboard_id" {
  description = "ID of the Cloud Monitoring dashboard"
  value       = try(google_monitoring_dashboard.main[0].id, null)
}

output "docker_push_command" {
  description = "Command to push Docker image to Artifact Registry"
  value       = "docker push ${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${local.image_name}:${var.container_image_tag}"
}

output "gcloud_run_logs_command" {
  description = "Command to view Cloud Run logs"
  value       = "gcloud logs read --service=cloud-run --resource=cloud_run_resource --limit=50"
}

output "gcloud_update_command" {
  description = "Command to deploy new image version"
  value       = "gcloud run deploy ${var.app_name} --image=${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/${local.image_name}:latest --region=${var.gcp_region}"
}
