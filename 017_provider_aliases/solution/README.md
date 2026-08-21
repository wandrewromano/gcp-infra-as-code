# 017 — Solution: Provider Aliases

## What this creates

- One `google_compute_network` (global).
- Two `google_compute_subnetwork`s in that network — one created by
  the default provider (region `us-central1`), one created by the
  `google.europe` aliased provider (region `europe-west1`) — neither
  resource sets `region` directly.

## Why a second provider block instead of two `region` arguments

For *this specific case*, you're right that setting `region`
explicitly on each subnetwork would be simpler — and the discussion
question is pointing at exactly that. Provider aliases earn their
keep when the difference between two targets **isn't expressible as a
resource argument at all**:

- **Two entirely different GCP projects** — `project` is set on the
  provider, and plenty of setups need to create resources in project
  A that reference or depend on resources in project B (e.g. a shared
  VPC host project and a service project).
- **Two different sets of credentials** — a provider block can carry
  its own `credentials`/`impersonate_service_account`, letting one
  configuration act as two different identities.
- **A provider-level setting with no per-resource equivalent** — e.g.
  `user_project_override` and `billing_project`, which control which
  project gets billed for API calls, independent of which project a
  resource lives in.

Region happens to have a resource-level escape hatch; not everything
does. This exercise uses region because it's the one difference you
can meaningfully demonstrate with a single GCP project — the
mechanism (`alias`, `provider = google.xyz`) is identical for the
project/credentials cases you'd actually reach for this in practice.

## Things worth noticing

- `provider = google.europe` is how a resource opts into a
  **non-default** provider configuration. Omit it, and a resource
  always uses the default (unaliased) `provider "google"` block.
- Every `provider "google" { ... }` block beyond the first **must**
  have an `alias` — Terraform won't let you define two unaliased
  provider blocks for the same provider in one configuration.
- `required_providers` in the `terraform` block is declared once, not
  once per alias — aliases are a configuration-level concept, not a
  separate provider installation.
