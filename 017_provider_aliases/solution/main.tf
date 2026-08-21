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

provider "google" {
  alias   = "europe"
  project = var.project_id
  region  = "europe-west1"
}

resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "this" {
  name                    = "provider-aliases-network"
  auto_create_subnetworks = false

  depends_on = [google_project_service.compute]
}

resource "google_compute_subnetwork" "us" {
  name          = "provider-aliases-us-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.this.id
  # No region set — inherits us-central1 from the default provider.
}

resource "google_compute_subnetwork" "europe" {
  provider = google.europe

  name          = "provider-aliases-europe-subnet"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.this.id
  # No region set — inherits europe-west1 from the aliased provider.
}
