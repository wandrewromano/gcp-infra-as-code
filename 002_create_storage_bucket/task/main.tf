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
  project = "training-project-11-f0a7d1" # TODO: your project ID
  region  = "us-central1"
}

# TODO: define a google_storage_bucket resource named "my_bucket"
resource google_storage_bucket "my_bucket" {
  name = "training-project-11-f0a7d1-002"
  location = "us-central1"
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
