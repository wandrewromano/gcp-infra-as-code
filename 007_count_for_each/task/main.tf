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

# TODO: google_storage_bucket "this" with for_each = var.bucket_environments
resource google_storage_bucket "my_bucket" {
  for_each = var.bucket_environments
  name = "${var.project_id}-${each.value}-bucket"
  location = var.region
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

# TODO: output "bucket_urls" mapping each environment to its bucket's url
