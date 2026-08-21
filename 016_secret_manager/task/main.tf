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

# TODO: google_project_service "secretmanager" (secretmanager.googleapis.com)

# TODO: google_secret_manager_secret "app_secret"
# - secret_id = "app-secret"
# - replication { auto {} }
#
# Do NOT define a google_secret_manager_secret_version resource here.
# The actual value goes in out-of-band — see README.md step 4 — on
# purpose, so it never becomes a Terraform-managed value at all.
