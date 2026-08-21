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
  alias = "europe"
  project = var.project_id
  region = "europe-west1"
}

resource "google_compute_network" "this" {
    name                    = "my-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "us" {
  name          = "my-subnet-us"
  ip_cidr_range = "192.168.0.0/24"  # a /24, e.g. "10.0.1.0/24"
  network       = google_compute_network.this.id  # reference the network resource above by its `id`
}

resource "google_compute_subnetwork" "europe" {
  provider = google.europe
  name          = "my-subnet-europe"
  ip_cidr_range = "192.168.0.0/24"  # a /24, e.g. "10.0.1.0/24"
  network       = google_compute_network.this.id  # reference the network resource above by its `id`
}



# TODO: provider "google" { alias = "europe", project = var.project_id, region = "europe-west1" }

# TODO: google_compute_network "this" (global, default provider)

# TODO: google_compute_subnetwork "us" — default provider, no explicit region

# TODO: google_compute_subnetwork "europe" — provider = google.europe, no explicit region
