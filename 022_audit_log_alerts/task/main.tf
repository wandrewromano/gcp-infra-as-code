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

resource "google_storage_bucket" "drift_demo" {
  name                        = "${var.project_id}-drift-bucket"
  location                    = var.region

  force_destroy               = true
  uniform_bucket_level_access = true
  labels = {
    environment = "dev"
  }
}

resource "google_logging_metric" "manual_bucket_changes" {
  name   = "${var.project_id}-drift-detection"

  filter = <<-EOT
    resource.type="gcs_bucket"
    resource.labels.bucket_name="${google_storage_bucket.drift_demo.name}"
    protoPayload.methodName="storage.buckets.patch"
    NOT protoPayload.requestMetadata.callerSuppliedUserAgent:"Terraform"
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_notification_channel" "notification_channel" {
  display_name = "Drift alerts"
  type         = "email"

  labels = {
    email_address = var.notification_email
  }
}

resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "my alert policy"
  combiner     = "OR"

  conditions {
    display_name = "condition 1"

    condition_threshold {
      filter          = "resource.type=\"gcs_bucket\" AND metric.type=\"logging.googleapis.com/user/${google_logging_metric.manual_bucket_changes.name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_COUNT"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.notification_channel.id]
}
