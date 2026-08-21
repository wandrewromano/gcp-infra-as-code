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

# TODO: define a google_storage_bucket resource named "my_bucket"
resource google_storage_bucket "my_bucket" {
  name = var.bucket_name
  location = var.region
  uniform_bucket_level_access = true
  force_destroy = true

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


resource "google_storage_bucket_object" "hello" {
  name   = "hello.txt"
  bucket = google_storage_bucket.my_bucket.name
  source = "hello.txt"
}
