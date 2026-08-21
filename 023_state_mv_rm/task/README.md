# 023 — terraform state mv / rm

**Goal:** refactor a resource's address in your code without
destroying and recreating the real thing, and understand what
`terraform state rm` actually does (and doesn't) touch.

[Visit the Official Terraform State Management Tutorial Here](https://developer.hashicorp.com/terraform/tutorials/state/state-cli)

## Setup

`variables.tf` already has `project_id`/`region` pre-filled — that
part goes back to [003_variables_and_outputs](../003_variables_and_outputs).
`terraform.tfvars` is already here too, committed with placeholder
values — just edit `project_id` to your real project ID (see 003's
README for why this file is committed instead of gitignored).

## Tasks

1. Define a `google_storage_bucket` resource named `legacy`
   (`resource "google_storage_bucket" "legacy"`) and `terraform
   apply` it.
2. Rename it in code — change the resource label from `"legacy"` to
   `"renamed"` — and nothing else. Run `terraform plan`. Don't apply
   it. Read the plan carefully: what does Terraform propose to do,
   and why, given the bucket's actual configuration didn't change at
   all?
3. Undo that risk with `terraform state mv`:
   ```bash
   terraform state mv google_storage_bucket.legacy google_storage_bucket.renamed
   ```
   Run `terraform plan` again — it should now show **no changes**.
4. Now try the opposite direction:
   ```bash
   terraform state rm google_storage_bucket.renamed
   terraform state list
   ```
   Run `terraform plan` once more. What does Terraform propose this
   time — and what would actually happen to the real bucket in GCP if
   you applied it? (Don't apply it.)
5. Bring it back under management with the classic import command:
   ```bash
   terraform import google_storage_bucket.renamed YOUR_BUCKET_NAME
   ```
6. Run `terraform plan` one final time and confirm it's back to
   showing no changes.

## Success criteria

Across the whole exercise, the real bucket in GCP is created exactly
once and never destroyed or recreated — only Terraform's *state*
changed, three times, while you moved it around.

## Discussion question

`terraform state rm` doesn't touch the real resource at all — only
Terraform's own bookkeeping. Why would running that against a
standalone bucket (like this one) be a lot less risky than running it
against, say, a `google_compute_network` that three other resources
reference via `network = google_compute_network.this.id`?
