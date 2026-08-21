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

# TODO: google_compute_network + google_compute_subnetwork (from 008/010)

# TODO: google_compute_firewall "this" with:
# - allow { protocol = "tcp", ports = ["22"] }
# - allow { protocol = "tcp", ports = ["80", "443"] }
# - source_ranges = var.environment == "prod" ? ["35.235.240.0/20"] : ["0.0.0.0/0"]
