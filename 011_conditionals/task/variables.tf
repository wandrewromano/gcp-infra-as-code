variable "project_id" {
  description = "GCP project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "Region for the subnet and provider default."
  type        = string
  default     = "us-central1"
}

# TODO: this is the same validated "environment" variable from
# 005_variable_validation — copy it forward (string, default "dev",
# with the validation block restricting it to dev/staging/prod).
# Don't write a plain, unvalidated version from scratch.
