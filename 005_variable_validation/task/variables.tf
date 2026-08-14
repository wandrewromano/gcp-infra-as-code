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
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "retention_days" {
  default = 30
  type = number
  validation {
    condition = var.retention_days >= 0
    error_message = "retention_days must be greater than or equal to 0"
  }
  
}

# TODO: this is the same "environment" variable you defined in
# 004_locals — copy it forward (string, default "dev"), then add a
# validation block that only allows "dev", "staging", or "prod":
#
#   validation {
#     condition     = contains(["dev", "staging", "prod"], var.environment)
#     error_message = "environment must be one of: dev, staging, prod."
#   }

# TODO: variable "retention_days" (number, default 30) with a
# validation block requiring a positive number
