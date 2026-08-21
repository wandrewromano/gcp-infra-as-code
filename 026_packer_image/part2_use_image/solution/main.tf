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

resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "example" {
  name                    = "packer-example-network"
  auto_create_subnetworks = false

  depends_on = [google_project_service.compute]
}

resource "google_compute_subnetwork" "example" {
  name          = "packer-example-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.example.id
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "packer-allow-ssh-iap"
  network = google_compute_network.example.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "packer-allow-http"
  network = google_compute_network.example.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_instance" "example" {
  name         = "example-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  tags         = ["ssh", "http-server"]

  boot_disk {
    initialize_params {
      image = "projects/${var.project_id}/global/images/family/app-server"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.example.id
    access_config {} # ephemeral public IP
  }

  # No metadata_startup_script — Apache is already installed in the
  # image itself. That's the whole point of this exercise.

  depends_on = [google_project_service.compute]
}

output "vm_external_ip" {
  value = google_compute_instance.example.network_interface[0].access_config[0].nat_ip
}
