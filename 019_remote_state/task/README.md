# 019 — Remote State

**Goal:** move off local state and understand why teams don't commit
`terraform.tfstate` to git.

Every exercise so far has stored its `terraform.tfstate` — the record
Terraform keeps of what it created (see
[000_start_here](../../000_start_here) step 4 if that's unfamiliar)
— as a plain file in that exercise's own folder. A **backend** is
just where Terraform stores and reads that file from; `local` (the
default, which you've been using without ever naming it) reads/writes
a file on your own disk. This exercise switches to the `gcs` backend
instead, which stores it in a GCS bucket — necessary the moment more
than one person or machine needs to run `apply` against the same
infrastructure, since a file on your laptop isn't something a
teammate or a CI pipeline can read.

[Visit the Official Terraform GCS Backend Documentation Here](https://developer.hashicorp.com/terraform/language/backend/gcs)

## Setup

`variables.tf` already has `project_id`/`region` pre-filled — that
part goes back to [003_variables_and_outputs](../003_variables_and_outputs).
`terraform.tfvars` is already here too, committed with placeholder
values — just edit `project_id` to your real project ID (see 003's
README for why this file is committed instead of gitignored).

One exception this time: the `backend "gcs" { bucket = ... }` value
in step 2 below **cannot** be `var.project_id` or come from
`terraform.tfvars` — Terraform has to know where your state lives
before it evaluates any variables, so backend config is always a
hardcoded literal. Type your state bucket name directly into that
block.

## Tasks

1. Create a GCS bucket to hold state — you can do this once by hand
   (`gcloud storage buckets create`) or with a small bootstrap
   config, since a backend generally can't be created by the same
   configuration that uses it.
   - Enable `versioning` on this bucket so you can recover from a bad
     state write.
2. In `main.tf`, add a backend block:
   ```hcl
   terraform {
     backend "gcs" {
       bucket = "YOUR_STATE_BUCKET"
       prefix = "terraform-course/019-remote-state"
     }
   }
   ```
3. Run `terraform init` — Terraform should detect the backend change
   and offer to migrate your existing local state into GCS.
4. Confirm the state file now lives in the bucket:
   ```bash
   gcloud storage ls gs://YOUR_STATE_BUCKET/terraform-course/019-remote-state/
   ```
5. Delete your local `terraform.tfstate` (it should no longer be
   needed — GCS is now the source of truth) and run `terraform plan`
   again to confirm it still works.

## Success criteria

State lives in GCS, not on disk, and `terraform plan` works from a
clean checkout with no local state file.

## Discussion question

What problem does state *locking* solve, and how does the GCS backend
provide it?
