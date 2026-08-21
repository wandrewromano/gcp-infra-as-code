packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

variable "project_id" {
  type = string
}

source "googlecompute" "app_server" {
  project_id          = var.project_id
  source_image_family = "debian-12"
  zone                = "us-central1-a"
  image_name          = "app-server-{{timestamp}}"
  image_family        = "app-server"
  ssh_username        = "packer"
}

build {
  sources = ["source.googlecompute.app_server"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
    ]
  }
}
