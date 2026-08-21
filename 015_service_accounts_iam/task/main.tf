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

# TODO: google_storage_bucket resource (something to scope IAM to —
# same shape as earlier exercises)

# TODO: resource "google_service_account" "vm_runner" {
#   account_id   = "vm-runner"
#   display_name = "___"
# }

# TODO: resource "google_storage_bucket_iam_member" "vm_runner_object_viewer" {
#   bucket = ___  # reference the bucket resource above
#   role   = "roles/storage.objectViewer"
#   member = "serviceAccount:${___}"  # the service account's `email` attribute
#   # GCP IAM member strings always need a type prefix (serviceAccount:,
#   # user:, group:, etc.) — see the Argument Reference on the docs
#   # page above.
# }

# TODO: network, subnetwork, firewall rules (from exercise 013)

# TODO: google_compute_instance using the vm_runner service account
#       (see exercise 013 for the rest of the instance config) — add:
#   service_account {
#     email  = google_service_account.vm_runner.email
#     scopes = ["cloud-platform"]
#   }
