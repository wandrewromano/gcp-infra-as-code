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

# TODO: google_storage_bucket "legacy" — see README.md step 1.
# Later steps have you rename this resource's label yourself, in
# place, as part of the exercise.
