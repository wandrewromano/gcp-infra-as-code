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

# This is what `terraform plan -generate-config-out` produces for a
# bucket created with:
#   gcloud storage buckets create gs://YOUR_PROJECT_ID-imported-demo \
#     --location=us-central1 --uniform-bucket-level-access \
#     --labels=clickops_resource=true
# Note the location comes back uppercase from the API even though the
# gcloud command used lowercase — generated config reflects what the
# provider actually reads back, not what you typed.
resource "google_storage_bucket" "imported" {
  name                        = "your-gcp-project-id-imported-demo" # TODO: replace with your project ID
  location                    = "US-CENTRAL1"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  labels = {
    clickops_resource = "true"
  }
}
