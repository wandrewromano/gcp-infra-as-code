variable "project_id" {
  description = "GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "Region for the provider default."
  type        = string
  default     = "us-central1"
}

variable "notification_email" {
  description = "Email address to receive the drift alert — must be an address you can actually check during this exercise."
  type        = string
}
