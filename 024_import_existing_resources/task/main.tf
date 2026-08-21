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

# TODO: after running `terraform plan -generate-config-out=generated.tf`
# (see README.md), move the generated google_storage_bucket "imported"
# block from generated.tf into this file, then delete generated.tf.
