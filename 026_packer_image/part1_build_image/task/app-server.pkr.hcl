# TODO: packer { required_plugins { googlecompute = { ... } } } block —
# same shape as Terraform's `terraform { required_providers { ... } }`,
# just for Packer's plugins instead. Use:
#   source  = "github.com/hashicorp/googlecompute"
#   version = ">= 1.1.1"

# TODO: variable "project_id" { type = string } — same idea as every
# Terraform exercise's project_id variable, just declared in Packer's
# own HCL instead.

# TODO: source "googlecompute" "app_server" { ... } with:
# - project_id          = var.project_id
# - source_image_family = "debian-12"
# - zone                = "us-central1-a"
# - image_name          = "app-server-{{timestamp}}"
# - image_family        = "app-server"
# - ssh_username        = "packer"
#
# Note: {{timestamp}} is Packer's own templating syntax, not
# Terraform's ${...} interpolation — different tool, similar idea.

# TODO: build { sources = ["source.googlecompute.app_server"]
#   provisioner "shell" { inline = [...] }
# } — install apache2 with two inline commands, same package as
# 013_create_vm's startup script:
#   "sudo apt-get update"
#   "sudo apt-get install -y apache2"
