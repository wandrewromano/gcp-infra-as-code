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

# TODO: google_compute_network + google_compute_subnetwork + two
# firewall rules (SSH-via-IAP, HTTP) — same pattern as 013_create_vm.

# TODO: google_compute_instance "example", same shape as 013's, but:
# - boot_disk.initialize_params.image points at the family, not a
#   stock image:
#     image = "projects/${var.project_id}/global/images/family/app-server"
# - NO metadata_startup_script — Apache is already installed in the
#   image itself. See README.md for why this is the whole point.

# TODO: output "vm_external_ip" (same as 013's)
