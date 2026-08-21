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

# TODO: network, subnetwork, firewall rules (from exercises 008/010)

# TODO: resource "google_compute_instance" "example" {
#   name         = "___"
#   machine_type = "e2-micro"
#   zone         = "us-central1-a"
#   tags         = ["ssh", "http-server"]
#
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-12"
#     }
#   }
#
#   network_interface {
#     subnetwork = ___  # reference the subnetwork resource above
#     access_config {}  # empty block — this is what gets you a public IP
#   }
#
#   metadata_startup_script = <<-EOT
#     #!/bin/bash
#     apt-get update
#     apt-get install -y apache2
#   EOT
# }
#
# Optional: the google_compute_instance docs page above has many more
# arguments under Argument Reference, e.g. `labels`, `metadata`.
