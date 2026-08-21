terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "training-project-11-f0a7d1-tf-state" # TODO: same state bucket as 019
    prefix = "terraform-course/020-state-bucket-least-privilege"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# TODO: define a google_service_account "state_runner" — the identity
# that stands in for "whatever runs terraform apply" against this
# project (see README.md for why this isn't just your own user).

resource "google_service_account" "state_runner" {
  account_id   = "state-runner"
  display_name = "state-runner"
}

# TODO: grant state_runner roles/storage.objectAdmin on
# var.state_bucket_name ONLY, via google_storage_bucket_iam_member.
# Do not grant roles/storage.admin, and do not grant it at the
# project level.

resource "google_storage_bucket_iam_member" "state_runner_storage_object_admin" {
  member = "serviceAccount:${google_service_account.state_runner.email}"
  bucket = var.state_bucket_name
  role = "roles/storage.objectAdmin"
}

resource "google_storage_bucket_iam_member" "user_storage_object_viewer" {
  member = "user:${var.your_email}"
  bucket = var.state_bucket_name
  role = "roles/storage.objectViewer"
}

# TODO: grant your own user (var.your_email) roles/storage.objectViewer
# on var.state_bucket_name — read-only, standing in for a human who
# needs to inspect state while debugging, without the read/write
# access state_runner has.
