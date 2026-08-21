variable "project_id" {
  description = "GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "Region for the subnet and provider default."
  type        = string
  default     = "us-central1"
}

variable "allowed_ports" {
  type = list(object({
    protocol = string
    ports    = list(string)
  }))
  default = [
    { protocol = "tcp", ports = ["22"] },
    { protocol = "tcp", ports = ["80", "443"] },
  ]
}
