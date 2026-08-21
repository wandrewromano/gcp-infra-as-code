variable "project_id" {
  description = "GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "Region for the subnet and provider default."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Same validated variable from 004_locals / 005_variable_validation, carried forward as-is."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}
