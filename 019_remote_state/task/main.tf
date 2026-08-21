terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

backend "gcs" {
  bucket = "training-project-11-f0a7d1-tf-state"
  prefix = "terraform-course/019-remote-state"
  
}

  # TODO: add a backend "gcs" block pointing at a state bucket you
  # created ahead of time (see README.md step 1)
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# unimportant resource
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
