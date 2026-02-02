# Global Load Balancer (optional - for multi-region setup)
# This file contains configuration for global load balancing across Cloud Run services
# Uncomment to enable

# resource "google_compute_backend_service" "coffee_api" {
#   count         = var.enable_load_balancer ? 1 : 0
#   name          = "${var.app_name}-backend-service"
#   protocol      = "HTTPS"
#   timeout_sec   = var.container_timeout
#   port_name     = "http"
#
#   health_checks = [google_compute_health_check.coffee_api[0].id]
#
#   custom_request_headers {
#     headers = ["X-Client-Region:{client_region}"]
#   }
# }
#
# resource "google_compute_health_check" "coffee_api" {
#   count               = var.enable_load_balancer ? 1 : 0
#   name                = "${var.app_name}-health-check"
#   check_interval_sec  = 30
#   timeout_sec         = 5
#
#   http_health_check {
#     port               = var.container_port
#     request_path       = "/health"
#   }
# }
#
# resource "google_compute_url_map" "coffee_api" {
#   count           = var.enable_load_balancer ? 1 : 0
#   name            = "${var.app_name}-url-map"
#   default_service = google_compute_backend_service.coffee_api[0].id
#
#   host_rule {
#     hosts        = [var.custom_domain != null ? var.custom_domain : "${var.app_name}.example.com"]
#     path_matcher = "allpaths"
#   }
#
#   path_matcher {
#     name            = "allpaths"
#     default_service = google_compute_backend_service.coffee_api[0].id
#   }
# }
#
# resource "google_compute_target_https_proxy" "coffee_api" {
#   count            = var.enable_load_balancer ? 1 : 0
#   name             = "${var.app_name}-https-proxy"
#   url_map          = google_compute_url_map.coffee_api[0].id
#   ssl_certificates = [google_compute_ssl_certificate.coffee_api[0].id]
# }
#
# resource "google_compute_ssl_certificate" "coffee_api" {
#   count           = var.enable_load_balancer ? 1 : 0
#   name            = "${var.app_name}-ssl-cert"
#   private_key     = file("path/to/private.key")
#   certificate     = file("path/to/certificate.crt")
# }
#
# resource "google_compute_global_forwarding_rule" "coffee_api" {
#   count       = var.enable_load_balancer ? 1 : 0
#   name        = "${var.app_name}-global-fwd-rule"
#   target      = google_compute_target_https_proxy.coffee_api[0].id
#   port_range  = "443"
#   ip_protocol = "TCP"
# }
