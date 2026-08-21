variable "project_id" {
  description = "GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "Region for the provider default."
  type        = string
  default     = "us-central1"
}

variable "state_bucket_name" {
  description = "Name of the state bucket created in 019_remote_state."
  type        = string
}

variable "your_email" {
  description = "Your own GCP identity, e.g. output of `gcloud config get-value account` — stands in for a human who needs to inspect state for debugging, read-only."
  type        = string
}
