terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # TODO: add a backend "gcs" block pointing at a state bucket you
  # created ahead of time (see README.md step 1)
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Reuse any small resource from an earlier exercise (e.g. a storage
# bucket) — the point of this exercise is the backend, not the
# resource itself.
