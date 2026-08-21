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
  zone    = "us-central1-a"
}

# TODO: module "dev" {
#   source      = "./modules/vm_with_network"
#   name_prefix = "dev"
#   subnet_cidr = "10.0.1.0/24"
#   ...
# }

# TODO: module "staging" {
#   source      = "./modules/vm_with_network"
#   name_prefix = "staging"
#   subnet_cidr = "10.0.2.0/24"
#   ...
# }

# TODO: root outputs referencing module.dev.* and module.staging.*
