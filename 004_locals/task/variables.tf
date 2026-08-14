variable "project_id" {
  description = "GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "Region for the bucket and provider default."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  default = "dev"
  
}

# TODO: variable "environment" (string, default "dev").
# You'll add a `validation` block to this exact variable in
# 005_variable_validation — keep the name and type as described in
# README.md so that addition drops in cleanly.
