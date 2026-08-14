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


locals {
  name_prefix   = "${var.project_id}-${var.region}"
  common_labels = merge({ managed_by = "terraform" }, { environment = var.environment })
}

# TODO: google_storage_bucket "this" using local.name_prefix for its
# name and local.common_labels for its labels

resource google_storage_bucket "my_bucket" {
  name = "${local.name_prefix}-bucket"
  location = var.region
  uniform_bucket_level_access = true

  labels = local.common_labels

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
