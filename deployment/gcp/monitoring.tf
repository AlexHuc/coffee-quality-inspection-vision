# Cloud Logging Sink for Cloud Run logs
resource "google_logging_project_sink" "cloud_run" {
  count           = var.enable_monitoring ? 1 : 0
  name            = "${var.app_name}-logs-sink"
  destination     = "storage.googleapis.com/${google_storage_bucket.logs.name}"
  filter          = "resource.type=\"cloud_run_resource\" AND resource.labels.service_name=\"${var.app_name}\""
  unique_writer_identity = true
}

# Grant logging service account write access
resource "google_storage_bucket_iam_member" "logging_sink_writer" {
  bucket = google_storage_bucket.logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.cloud_run[0].writer_identity
}

# Cloud Monitoring Alert Policy - Request Rate
resource "google_monitoring_alert_policy" "request_rate" {
  count           = var.enable_monitoring ? 1 : 0
  display_name    = "${var.app_name} - High Request Rate"
  combiner        = "OR"
  enabled         = true

  conditions {
    display_name = "Request rate exceeds threshold"
    
    condition_threshold {
      filter          = "resource.type=\"cloud_run_resource\" AND resource.labels.service_name=\"${var.app_name}\" AND metric.type=\"run.googleapis.com/request_count\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1000
      
      aggregations {
        alignment_period    = "60s"
        per_series_aligner  = "ALIGN_RATE"
      }
    }
  }

  notification_channels = []
  documentation {
    content   = "Alert triggered when ${var.app_name} request rate exceeds 1000 requests per minute."
    mime_type = "text/markdown"
  }
}

# Cloud Monitoring Alert Policy - Error Rate
resource "google_monitoring_alert_policy" "error_rate" {
  count           = var.enable_monitoring ? 1 : 0
  display_name    = "${var.app_name} - High Error Rate"
  combiner        = "OR"
  enabled         = true

  conditions {
    display_name = "Error rate exceeds threshold"
    
    condition_threshold {
      filter          = "resource.type=\"cloud_run_resource\" AND resource.labels.service_name=\"${var.app_name}\" AND metric.type=\"run.googleapis.com/request_count\" AND metric.response_code_class=\"5xx\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 50
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = []
  documentation {
    content   = "Alert triggered when ${var.app_name} error rate exceeds 5% of total requests."
    mime_type = "text/markdown"
  }
}

# Cloud Monitoring Dashboard
resource "google_monitoring_dashboard" "main" {
  count          = var.enable_monitoring ? 1 : 0
  dashboard_json = jsonencode({
    displayName = "${var.app_name} Dashboard"
    mosaicLayout = {
      columns = 12
      tiles = [
        {
          width  = 6
          height = 4
          widget = {
            title = "Request Count"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"cloud_run_resource\" AND resource.labels.service_name=\"${var.app_name}\" AND metric.type=\"run.googleapis.com/request_count\""
                      aggregation = {
                        alignmentPeriod    = "60s"
                        perSeriesAligner   = "ALIGN_RATE"
                      }
                    }
                  }
                }
              ]
            }
          }
        },
        {
          xPos   = 6
          width  = 6
          height = 4
          widget = {
            title = "Request Latencies"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"cloud_run_resource\" AND resource.labels.service_name=\"${var.app_name}\" AND metric.type=\"run.googleapis.com/request_latencies\""
                      aggregation = {
                        alignmentPeriod   = "60s"
                        perSeriesAligner  = "ALIGN_PERCENTILE_95"
                      }
                    }
                  }
                }
              ]
            }
          }
        },
        {
          yPos   = 4
          width  = 6
          height = 4
          widget = {
            title = "CPU Utilization"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"cloud_run_resource\" AND resource.labels.service_name=\"${var.app_name}\" AND metric.type=\"run.googleapis.com/container_cpu_utilization\""
                      aggregation = {
                        alignmentPeriod   = "60s"
                        perSeriesAligner  = "ALIGN_MEAN"
                      }
                    }
                  }
                }
              ]
            }
          }
        },
        {
          xPos   = 6
          yPos   = 4
          width  = 6
          height = 4
          widget = {
            title = "Memory Utilization"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "resource.type=\"cloud_run_resource\" AND resource.labels.service_name=\"${var.app_name}\" AND metric.type=\"run.googleapis.com/container_memory_utilization\""
                      aggregation = {
                        alignmentPeriod   = "60s"
                        perSeriesAligner  = "ALIGN_MEAN"
                      }
                    }
                  }
                }
              ]
            }
          }
        }
      ]
    }
  })
}

# Optional: Cloud Scheduler for periodic health checks
resource "google_cloud_scheduler_job" "health_check" {
  count            = var.enable_monitoring ? 1 : 0
  name             = "${var.app_name}-health-check"
  description      = "Periodic health check for ${var.app_name}"
  schedule         = "*/5 * * * *"  # Every 5 minutes
  time_zone        = "UTC"
  attempt_deadline = "320s"

  http_target {
    http_method = "GET"
    uri         = "${google_cloud_run_v2_service.api.uri}/health"

    oidc_token {
      service_account_email = google_service_account.cloud_run.email
    }
  }
}
