# 022 — Alerting on Manual (Non-Terraform) Changes

**Goal:** turn the manual detection from
[021_configuration_drift](../021_configuration_drift) into a passive
one — get paged the moment someone changes a Terraform-managed
resource outside of Terraform, instead of finding out the next time
you happen to run `plan`.

[Visit the Official Cloud Audit Logs Overview Documentation Here](https://cloud.google.com/logging/docs/audit)

[Visit the Official Log-based Metrics Documentation Here](https://cloud.google.com/logging/docs/logs-based-metrics)

## Why a user-agent filter, not an identity filter

Every GCP API call — whether it came from `gcloud`, the Console, or
Terraform's own provider — is already recorded in Cloud Audit Logs,
including who made it. The obvious approach would be to alert on any
change made by a principal that *isn't* your Terraform identity, the
same way [020_state_bucket_least_privilege](../020_state_bucket_least_privilege)
scoped access by identity. That works when Terraform runs as its own
service account — but in this course, you've been applying every
exercise as your own `gcloud auth` login, and a manual `gcloud`
command you run yourself carries that exact same identity. Identity
alone can't tell `terraform apply` apart from you editing the same
resource by hand.

What *can* tell them apart: audit log entries record
`protoPayload.requestMetadata.callerSuppliedUserAgent`, and
Terraform's Google provider sets a distinctive one
(`Terraform/x.x.x ... terraform-provider-google/x.x.x`) that `gcloud`
and the Console don't. Filtering on that gets you a real signal in
this course's setup — but it's worth noticing going in that it's a
different *kind* of signal than 020's IAM boundary. Keep that
difference in mind for the discussion question.

## Setup

`variables.tf` already has `project_id`/`region` pre-filled — that
part goes back to [003_variables_and_outputs](../003_variables_and_outputs).
`terraform.tfvars` is already here too, committed with placeholder
values — edit `project_id` and `notification_email` (an address you
can actually check during this exercise) to your real values.

## Tasks

1. Rebuild the `drift_demo` bucket from
   [021_configuration_drift](../021_configuration_drift).
2. Define a `google_logging_metric` counting audit log entries that
   touch this bucket's configuration, where the caller's user agent
   does **not** contain `"Terraform"`:
   ```hcl
   filter = <<-EOT
     resource.type="gcs_bucket"
     resource.labels.bucket_name="${google_storage_bucket.drift_demo.name}"
     protoPayload.methodName="storage.buckets.patch"
     NOT protoPayload.requestMetadata.callerSuppliedUserAgent:"Terraform"
   EOT
   ```
3. Define a `google_monitoring_notification_channel` of type
   `"email"`, using `var.notification_email`.
4. Define a `google_monitoring_alert_policy` with one
   `condition_threshold` on the metric from step 2 (`metric.type =
   "logging.googleapis.com/user/<your metric's name>"`, `comparison =
   "COMPARISON_GT"`, `threshold_value = 0`), aggregated over a short
   window, notifying the channel from step 3.
5. Run `terraform apply`.
6. Drift the bucket by hand, exactly like
   [021_configuration_drift](../021_configuration_drift) step 3:
   ```bash
   gcloud storage buckets update gs://YOUR_BUCKET \
     --update-labels=environment=prod,clickops_resource=true
   ```
   Within a few minutes, confirm an incident opened — check your email
   or `gcloud alpha monitoring policies list` / the Console's
   Monitoring → Alerting page.
7. Now fix the drift with `terraform apply` (Option A from 021) and
   confirm this does **not** open a new incident — Terraform's own
   change carries the `"Terraform"` user agent, so your filter
   excludes it.
8. Run `terraform destroy` when finished.

## Success criteria

A manual `gcloud` (or Console) change to the bucket opens an alert
incident within minutes; the same change applied through Terraform
does not.

## Discussion question

This alert trusts a User-Agent string the caller supplies about
itself — nothing stops someone from hand-crafting an API call that
claims to be Terraform, the way nothing stops anyone from typing a
fake `From:` address in an email. Contrast that with
[020_state_bucket_least_privilege](../020_state_bucket_least_privilege)'s
IAM boundary, which GCP itself enforces regardless of what the caller
claims. What does that difference mean for how you'd actually use this
alert — is it something you'd wire up to auto-revert the change, or
just something that tells a human to go look?
