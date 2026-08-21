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
# Optional if you already ran `gcloud services enable` by hand — see
# README.md step 1.

resource "google_compute_network" "my_network" {
  name                    = "my-network"
  auto_create_subnetworks = false
  depends_on = [ google_project_service.compute ]
}

resource "google_compute_subnetwork" "example" {
  name          = "my-subnet"
  ip_cidr_range = "192.168.0.0/24"  # a /24, e.g. "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.my_network.id  # reference the network resource above by its `id`
}
