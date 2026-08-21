# 021 — Configuration Drift

**Goal:** see what happens when something Terraform manages gets
changed outside of Terraform, and learn the two different ways to
resolve it.

[Visit the Official Terraform Refresh-Only Mode Tutorial Here](https://developer.hashicorp.com/terraform/tutorials/state/refresh)

## Setup

`variables.tf` already has `project_id`/`region` pre-filled — that
part goes back to [003_variables_and_outputs](../003_variables_and_outputs).
`terraform.tfvars` is already here too, committed with placeholder
values — just edit `project_id` to your real project ID (see 003's
README for why this file is committed instead of gitignored).

## Tasks

1. Define a `google_storage_bucket` with a label:
   ```hcl
   labels = {
     environment = "dev"
   }
   ```
2. Run `terraform apply` and confirm the bucket exists with that
   label:
   ```bash
   gcloud storage buckets describe gs://YOUR_BUCKET --format="value(labels)"
   ```
3. Now change the label **outside Terraform**, simulating someone
   making a manual change in the Console or via the CLI. Also tag it
   `clickops_resource=true` — any time you touch a resource by hand
   instead of through Terraform, label it this way so it's easy to
   spot in the Console (see
   [000_start_here](../../000_start_here) step 6):
   ```bash
   gcloud storage buckets update gs://YOUR_BUCKET \
     --update-labels=environment=prod,clickops_resource=true
   ```
4. Run `terraform plan`. Don't apply anything yet — just read the
   output. Terraform noticed the real bucket no longer matches your
   code, and proposes changing it back.
5. You now have two legitimate options — try both, in order:
   - **Option A:** `terraform apply` — this reverts the manual change,
     putting the label back to `dev`. Code wins.
   - Manually drift it again
     (`--update-labels=environment=prod,clickops_resource=true`),
     then try **Option B:** `terraform apply -refresh-only` — this
     updates Terraform's *state* to match the real value (`prod`),
     without touching the actual bucket. Run `terraform plan`
     again afterward — what happens, and why?

## Success criteria

You can explain, in your own words, why Option B's `terraform plan`
right afterward shows the exact same diff as step 4 did — and what
you'd need to do differently to make that diff actually go away for
good.

## Cleanup

This bucket is Terraform-managed from the start, so a normal
`terraform destroy` removes it regardless of any manual label changes
you made along the way — the `clickops_resource` label is just for
visibility while you're working, not a cleanup requirement here.

## Discussion question

Terraform's default behavior is to treat your code as the source of
truth and revert anything that drifts from it. When would
`-refresh-only` be the right tool instead of a normal `apply` — i.e.
when is drift something you'd want your *code* to catch up to,
rather than something you want reverted?
