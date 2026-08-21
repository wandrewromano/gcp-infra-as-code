terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Backend config can't reference variables — it has to be a literal.
  # Create this bucket by hand first (see README.md step 1), then
  # `terraform init` to migrate local state into it.
  backend "gcs" {
    bucket = "your-gcp-project-id-tf-state" # TODO: replace with your state bucket
    prefix = "terraform-course/019-remote-state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "example" {
  name                        = "${var.project_id}-exercise-019"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}
