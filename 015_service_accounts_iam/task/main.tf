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


## Implemented compute service via `gcloud services enable compute.googleapis.com --project training-project-11-f0a7d1`
# resource "google_project_service" "compute" {
#   project            = var.project_id
#   service            = "compute.googleapis.com"
#   disable_on_destroy = false
# }


resource google_storage_bucket "my_bucket" {
  name = "training-project-11-f0a7d1-002"
  location = "us-central1"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }
}

resource "google_service_account" "vm_runner" {
  account_id   = "vm-runner"
  display_name = "vm-runner"
}

resource "google_storage_bucket_iam_member" "vm_runner_object_viewer" {
  bucket = google_storage_bucket.my_bucket.name  # reference the bucket resource above
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.vm_runner.email}"  # the service account's `email` attribute
  # GCP IAM member strings always need a type prefix (serviceAccount:,
  # user:, group:, etc.) — see the Argument Reference on the docs
  # page above.
}

resource "google_compute_network" "my_network" {
  name                    = "my-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "example" {
  name          = "my-subnet"
  ip_cidr_range = "192.168.0.0/24"  # a /24, e.g. "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.my_network.id  # reference the network resource above by its `id`
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "allow-iap-22"
  network = google_compute_network.my_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-80"
  network = google_compute_network.my_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_instance" "example" {
  name         = "freebie"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  tags         = ["ssh", "http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.example.name   # reference the subnetwork resource above
    access_config {}  # empty block — this is what gets you a public IP
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
  EOT

  service_account {
    email = google_service_account.vm_runner.email
    scopes = ["cloud-platform"]
  }
}



output "vm_external_ip" {
  value = google_compute_instance.example.network_interface[0].access_config[0].nat_ip
}