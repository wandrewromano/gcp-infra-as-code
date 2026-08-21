variable "project_id" {
  description = "GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "Region for the default provider."
  type        = string
  default     = "us-central1"
}
