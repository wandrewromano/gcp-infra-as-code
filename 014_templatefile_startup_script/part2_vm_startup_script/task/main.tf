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
  zone    = "us-central1-a"
}

# TODO: network, subnetwork, firewall rules, VM (from exercise 013)

# TODO: google_compute_instance "this" with:
# metadata_startup_script = templatefile("${path.module}/templates/startup.sh.tftpl", {
#   welcome_message = var.welcome_message
# })
