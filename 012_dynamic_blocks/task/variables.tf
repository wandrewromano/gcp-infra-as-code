variable "project_id" {
  description = "GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "Region for the subnet and provider default."
  type        = string
  default     = "us-central1"
}

# TODO: variable "allowed_ports" (list of objects with protocol/ports)
