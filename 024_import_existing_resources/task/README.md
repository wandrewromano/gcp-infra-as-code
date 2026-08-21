# 024 — Migrating Existing Resources

**Goal:** bring a resource that already exists in GCP — but was never
created by Terraform — under Terraform's management, using an
`import` block.

[Visit the Official Terraform Import Tutorial Here](https://developer.hashicorp.com/terraform/tutorials/state/state-import)

## Setup

`variables.tf` already has `project_id`/`region` pre-filled — that
part goes back to [003_variables_and_outputs](../003_variables_and_outputs).
`terraform.tfvars` is already here too, committed with placeholder
values — just edit `project_id` to your real project ID (see 003's
README for why this file is committed instead of gitignored).

## Tasks

1. Create a bucket **entirely outside Terraform**, simulating
   something that existed before this configuration did. Label it
   `clickops_resource=true` as you create it — any resource you make
   by hand instead of through Terraform should be tagged this way so
   it's identifiable in the Console (see
   [000_start_here](../../000_start_here) step 6):
   ```bash
   gcloud storage buckets create gs://YOUR_PROJECT_ID-imported-demo \
     --location=us-central1 \
     --uniform-bucket-level-access \
     --labels=clickops_resource=true
   ```
2. In `imports.tf`, add an `import` block pointing at it. Unlike the
   `backend` block in [019_remote_state](../019_remote_state), an
   `import` block *is* evaluated after your variables, so you can
   (and should) build the `id` from `var.project_id` instead of
   typing your project ID a second time:
   ```hcl
   import {
     to = google_storage_bucket.imported
     id = "${var.project_id}-imported-demo"
   }
   ```
3. Ask Terraform to generate a matching resource block for you,
   instead of writing it by hand:
   ```bash
   terraform init
   terraform plan -generate-config-out=generated.tf
   ```
   This reads the real bucket through the provider and writes a
   `google_storage_bucket "imported"` block into `generated.tf` that
   matches it — **nothing is created or changed**, this is still just
   a plan.
4. Open `generated.tf` and read it. Notice that its `name` comes back
   as a plain string literal, not `"${var.project_id}-imported-demo"`
   — `-generate-config-out` writes exactly what the provider read
   back from the real bucket, with no idea your project ID is a
   variable elsewhere in this config. That's fine for this one field;
   it's a reasonable prompt to go back and swap it for `var.project_id`
   yourself once you've moved the block into `main.tf`, but it isn't
   required for the exercise. Move the generated contents into
   `main.tf` (cleaning up anything you don't need to manage
   explicitly), then delete `generated.tf`.
5. Run `terraform plan` again. It should now show **no changes** —
   proof the resource is fully and accurately described in your code.
6. Confirm the bucket is genuinely under Terraform's management:
   ```bash
   terraform state list
   ```
   `google_storage_bucket.imported` should appear.

## Success criteria

`terraform plan` shows zero changes after the import, and
`terraform state list` includes the imported bucket.

## Cleanup

Once `google_storage_bucket.imported` shows up in `terraform state
list`, it's fully Terraform-managed — a normal `terraform destroy`
removes it like anything else in this course.

If you stop partway through — the bucket exists but you never
finished the `import` step — Terraform doesn't know it exists yet, so
`terraform destroy` won't touch it. Delete it by hand:

```bash
gcloud storage buckets delete gs://YOUR_PROJECT_ID-imported-demo
```

Either way, sweep for anything you might have left behind before
moving on:

```bash
gcloud storage buckets list --filter="labels.clickops_resource=true"
```

## Discussion question

Terraform also has a classic `terraform import <address> <id>` CLI
command, which only writes to state — it doesn't generate any code
for you; you have to hand-write a matching resource block yourself
*before* running it, then hope it matches. Why might the `import`
block + `-generate-config-out` approach used here fit better in a
CI/GitOps pipeline where nobody is running commands interactively?
