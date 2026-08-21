terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "your-gcp-project-id-tf-state" # TODO: replace with your state bucket
    prefix = "terraform-course/020-state-bucket-least-privilege"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_service_account" "state_runner" {
  account_id   = "state-runner"
  display_name = "State runner (exercise 020)"
}

# Object-level access only — enough to read/write state. Deliberately
# not roles/storage.admin: state_runner can use the bucket but can't
# change who else is allowed to.
resource "google_storage_bucket_iam_member" "state_runner_object_admin" {
  bucket = var.state_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.state_runner.email}"
}

# A human debugging state gets read-only — no write access at all,
# let alone the ability to change the bucket's own IAM policy.
resource "google_storage_bucket_iam_member" "human_reader" {
  bucket = var.state_bucket_name
  role   = "roles/storage.objectViewer"
  member = "user:${var.your_email}"
}
