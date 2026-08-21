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

module "logs" {
  source = "./modules/bucket_with_lifecycle"

  name     = "${var.project_id}-logs"
  age_days = 14
}

module "backups" {
  source = "./modules/bucket_with_lifecycle"

  name     = "${var.project_id}-backups"
  age_days = 90
}
