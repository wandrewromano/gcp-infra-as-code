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

resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "this" {
  name                    = "conditionals-network"
  auto_create_subnetworks = false

  depends_on = [google_project_service.compute]
}

resource "google_compute_subnetwork" "this" {
  name          = "conditionals-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.this.id
}

resource "google_compute_firewall" "this" {
  name    = "conditionals-allow"
  network = google_compute_network.this.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = var.environment == "prod" ? ["35.235.240.0/20"] : ["0.0.0.0/0"]
}
