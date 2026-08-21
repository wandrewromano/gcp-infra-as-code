terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Rebuild the same bucket from 021_configuration_drift:
# TODO: google_storage_bucket "drift_demo"
# - force_destroy = true
# - uniform_bucket_level_access = true
# - labels = { environment = "dev" }

# TODO: google_logging_metric "manual_bucket_changes" — a log-based
# metric that counts Cloud Audit Log entries where:
# - resource.type = "gcs_bucket"
# - resource.labels.bucket_name = this bucket's name
# - protoPayload.methodName = "storage.buckets.patch"
# - protoPayload.requestMetadata.callerSuppliedUserAgent does NOT
#   contain "Terraform" (see README.md for why this is the signal,
#   not the caller's identity)
# Give it a metric_descriptor block: metric_kind = "DELTA",
# value_type = "INT64", unit = "1".

# TODO: google_monitoring_notification_channel "email" — type =
# "email", labels = { email_address = var.notification_email }

# TODO: google_monitoring_alert_policy "manual_bucket_changes" — one
# condition_threshold on the log-based metric above
# (metric.type = "logging.googleapis.com/user/<metric name>"),
# comparison COMPARISON_GT, threshold_value 0, an aggregation that
# counts entries over a short window (e.g. alignment_period "300s",
# per_series_aligner "ALIGN_COUNT"), notifying the channel above.
