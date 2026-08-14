variable "project_id" {
  description = "GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "Region for the bucket and provider default."
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
    type = string
}