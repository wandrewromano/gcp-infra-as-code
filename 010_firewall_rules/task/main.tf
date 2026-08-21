terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# TODO: google_compute_network + google_compute_subnetwork (from exercise 008)
resource "google_compute_network" "my_network" {
  name                    = "my-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "example" {
  name          = "my-subnet"
  ip_cidr_range = "192.168.0.0/24"  # a /24, e.g. "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.my_network.id  # reference the network resource above by its `id`
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "allow-iap-22"
  network = google_compute_network.my_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-80"
  network = google_compute_network.my_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
#
# Optional: the google_compute_firewall docs page above has more under
# Argument Reference, e.g. `priority`, `direction`, `deny`.
