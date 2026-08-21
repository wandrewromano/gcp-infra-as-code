# 019 — Solution: Remote State

## What this creates

- A `backend "gcs"` configuration (not a resource — this changes
  *where Terraform stores its own state*, not what's in GCP).
- A small `google_storage_bucket` resource, included only so there's
  something in state to observe.

## Why remote state

By default, Terraform writes state to a single local file,
`terraform.tfstate`. That's fine solo, and breaks down the moment
more than one person or machine runs Terraform against the same
infrastructure: two people applying at the same time can corrupt the
file or silently overwrite each other's changes, and there's no
shared source of truth for "what does this environment currently look
like." A GCS backend fixes both problems — state lives in one place
everyone (and CI) reads from, and GCS backends support **state
locking**, so a second `apply` started while one is already running
waits (or fails clearly) instead of racing.

## Things worth noticing

- **Backend blocks can't reference variables, locals, or any other
  expression** — only literal strings. Terraform needs to know where
  the state lives before it can evaluate anything else, so this is
  one of the few places in a `.tf` file where you're stuck
  hardcoding a value (see the `# TODO` in `main.tf`).
- Because of that, the state bucket generally has to be created
  *before* this config is ever `init`'d — you can't have a
  configuration's own backend depend on a resource that same
  configuration creates. That's why the README asks you to create it
  by hand (or with a small separate "bootstrap" config) first.
- The first `terraform init` after adding a backend block will offer
  to **migrate** your existing local state into GCS — say yes, and
  from then on `terraform.tfstate` locally becomes a thin pointer,
  not the source of truth.
- State files can contain sensitive values in plaintext (e.g.
  generated passwords, private keys some providers return). Treat the
  state bucket's IAM as sensitive infrastructure in its own right —
  don't leave it broadly readable.
