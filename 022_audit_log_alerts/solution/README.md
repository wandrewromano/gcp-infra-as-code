# 022 — Solution: Alerting on Manual (Non-Terraform) Changes

## What this creates

- The `drift_demo` bucket from
  [021_configuration_drift](../021_configuration_drift).
- **`google_logging_metric.manual_bucket_changes`** — a log-based
  metric counting audit log entries that patch this bucket's
  configuration from anything whose user agent doesn't contain
  `"Terraform"`.
- **`google_monitoring_notification_channel.email`** and
  **`google_monitoring_alert_policy.manual_bucket_changes`** — fires
  whenever that metric ticks above zero.

## Why the filter keys on `callerSuppliedUserAgent`, not identity

See the task README's "Why a user-agent filter, not an identity
filter" section — the short version is that this course runs every
exercise as your own `gcloud auth` login, so a manual change and a
Terraform-applied change share the same principal. HashiCorp's Google
provider tags every request it makes with a distinctive user agent
string; `gcloud` and the Console don't. That's the only signal
available here that actually distinguishes "Terraform did this" from
"a human did this," in a course where there's no separate CI identity
to key off of instead.

## Why `NOT ... :"Terraform"` and not an exact match

The `:` operator in Cloud Logging's filter syntax is a substring
("has") match, not equality — the real user agent string looks like
`Terraform/1.9.0 (+https://www.terraform.io) terraform-provider-google/5.40.0`,
which varies by Terraform and provider version. Matching the literal
substring `"Terraform"` is stable across version bumps; an exact-match
filter would break the first time you upgraded either.

## Things worth noticing

- This is a *detection*, not a *boundary* — nothing here stops the
  manual change from happening, or reverts it automatically. That's
  the same distinction [021_configuration_drift](../021_configuration_drift)
  draws between the two ways of resolving drift once you've noticed
  it: this exercise only gets you to "noticed," faster.
- The alert fires on the **metric**, not on the raw audit log
  directly — `google_monitoring_alert_policy` conditions read from
  Cloud Monitoring metrics, so the log-based metric in step 2 is what
  bridges Cloud Logging (where the audit trail lives) to Cloud
  Monitoring (where the alerting engine lives).
- Compare this alert's trust model to
  [020_state_bucket_least_privilege](../020_state_bucket_least_privilege)'s:
  020's boundary is enforced by GCP's IAM system regardless of what
  the caller claims about itself; this one is a heuristic over a
  self-reported string, which is genuinely spoofable by anyone
  motivated enough to hand-craft the request. Useful for catching
  ordinary clickops, not adversarial tampering — see the discussion
  question.
