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

# TODO: provider "google" { alias = "europe", project = var.project_id, region = "europe-west1" }

# TODO: google_compute_network "this" (global, default provider)

# TODO: google_compute_subnetwork "us" — default provider, no explicit region

# TODO: google_compute_subnetwork "europe" — provider = google.europe, no explicit region
