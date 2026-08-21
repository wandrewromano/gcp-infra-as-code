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

# TODO: google_storage_bucket "drift_demo"
# - force_destroy = true
# - uniform_bucket_level_access = true
# - labels = { environment = "dev" }

resource "google_storage_bucket" "drift_demo" {
  name = "${var.project_id}-drift-bucket"
  location = var.region
  
  force_destroy = true
  uniform_bucket_level_access = true
  labels = {
    environment = "dev"
  }
  
}