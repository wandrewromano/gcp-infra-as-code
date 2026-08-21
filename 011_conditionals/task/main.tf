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



## Implemented via `gcloud services enable compute.googleapis.com --project training-project-11-f0a7d1`
# resource "google_project_service" "compute" {
#   project            = var.project_id
#   service            = "compute.googleapis.com"
#   disable_on_destroy = false
# }

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

resource "google_compute_firewall" "allow_rules" {
  name    = "allow-22-80-443-${var.environment}"
  network = google_compute_network.my_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "tcp"
    ports = ["80","443"]
  }

  source_ranges = ( var.environment == "prod" ? ["35.235.240.0/20"] : ["0.0.0.0/0"])
  target_tags   = ["base"]
}

# TODO: google_compute_network + google_compute_subnetwork (from 008/010)

# TODO: google_compute_firewall "this" with:
# - allow { protocol = "tcp", ports = ["22"] }
# - allow { protocol = "tcp", ports = ["80", "443"] }
# - source_ranges = var.environment == "prod" ? ["35.235.240.0/20"] : ["0.0.0.0/0"]
