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
}

resource "google_compute_network" "this" {
  name                    = "my-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  for_each = toset(var.subnet_names)
  name          = format("%s-%s-subnet", var.project_id, each.value)
  ip_cidr_range = cidrsubnet(var.network_cidr, 8, index(var.subnet_names, each.value))
  region        = var.region
  network       = google_compute_network.this.id 
}


# TODO: google_storage_bucket "this" (reuse the pattern from earlier exercises)
resource "google_storage_bucket" "this"{
  name = "${local.name_prefix}-bucket-009"
  location = var.region
  uniform_bucket_level_access = true
  force_destroy = true
}

resource "google_storage_bucket_object" "network_manifest" {
  name    = "network-manifest.json"
  bucket  = google_storage_bucket.this.name
  content = jsonencode({
    network_cidr = var.network_cidr
    subnets      = { for name, s in google_compute_subnetwork.this : name => s.ip_cidr_range }
  })
}