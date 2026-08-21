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
# - dynamic "allow" { for_each = var.allowed_ports; content { ... } }
# - source_ranges = ["35.235.240.0/20"] (fixed — no conditional here,
#   that's 011's concept, not this one)
