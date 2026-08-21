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

resource "google_storage_bucket" "example" {
  name                        = "${var.project_id}-exercise-015"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_service_account" "vm_runner" {
  account_id   = "vm-runner"
  display_name = "VM runner (exercise 015)"
}

# Scoped to this one bucket only — not project-wide storage admin.
resource "google_storage_bucket_iam_member" "vm_runner_object_viewer" {
  bucket = google_storage_bucket.example.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.vm_runner.email}"
}

resource "google_compute_network" "example" {
  name                    = "example-network"
  auto_create_subnetworks = false

  depends_on = [google_project_service.compute]
}

resource "google_compute_subnetwork" "example" {
  name          = "example-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.example.id
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "allow-ssh-iap"
  network = google_compute_network.example.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["ssh"]
}

resource "google_compute_instance" "example" {
  name         = "example-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.example.id
    access_config {}
  }

  service_account {
    email  = google_service_account.vm_runner.email
    scopes = ["cloud-platform"]
  }

  depends_on = [google_project_service.compute]
}
