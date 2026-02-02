# VPC Network for Cloud Run (optional)
# Cloud Run is serverless and doesn't require explicit VPC setup
# This is provided for advanced networking scenarios

resource "google_compute_network" "main" {
  name                    = "${var.app_name}-network"
  auto_create_subnetworks = true
  routing_mode            = "REGIONAL"
}

# Firewall rule to allow Cloud Run traffic
resource "google_compute_firewall" "allow_run" {
  name    = "${var.app_name}-allow-run"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = [var.container_port]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.app_name]
}

# Cloud NAT for outbound traffic (if using VPC connector)
resource "google_compute_router" "router" {
  name    = "${var.app_name}-router"
  region  = var.gcp_region
  network = google_compute_network.main.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.app_name}-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
