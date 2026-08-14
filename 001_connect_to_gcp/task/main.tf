terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source = "hashicorp/google"
      # TODO: pin a provider version, e.g. "~> 5.0"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "training-project-11-f0a7d1" # TODO: replace with your project ID
  region  = "us-central1"
}

data "google_project" "this" {
  # No project_id set — this defaults to the provider's configured
  # project above, so there's only one place to put your project ID.
}

output "project_display_name" {
  value = data.google_project.this.name
}
