# 018 — Build a Module

**Goal:** learn what a module actually is — any folder with `.tf`
files, called with a `source` argument — by wrapping something you've
already built into one, then reusing it twice.

[Visit the Official Terraform Module Tutorial Here](https://developer.hashicorp.com/terraform/tutorials/modules/module-create)

## Setup

The root `variables.tf` already has `project_id`/`region` pre-filled
— that part goes back to
[003_variables_and_outputs](../003_variables_and_outputs) — this
applies to the root config that *calls* the module, same as always.
The root `terraform.tfvars` is already here too, committed with
placeholder values — just edit `project_id` to your real project ID.
The module itself gets its own separate `variables.tf` in step 1
below, with inputs like `name`/`location`/`age_days` — modules never
read your root `terraform.tfvars` directly, they only see what the
root config passes in through the `module` block.

## Tasks

1. Inside `modules/bucket_with_lifecycle/`, build a small module that
   creates a storage bucket with versioning and an age-based deletion
   rule (the same pattern from
   [002_create_storage_bucket](../../002_create_storage_bucket)'s
   stretch goal), but generalized:
   - `variables.tf`: `name` (string, required), `location` (string,
     default `"US"`), `age_days` (number, default `30`).
   - `main.tf`: a `google_storage_bucket` using those variables —
     `uniform_bucket_level_access = true`, `versioning { enabled =
     true }`, and a `lifecycle_rule` whose `condition.age` comes from
     `var.age_days`.
   - `outputs.tf`: `bucket_url` and `bucket_name`.
2. In the root `main.tf`, call the module **twice**:
   - a `logs` bucket with `age_days = 14`
   - a `backups` bucket with `age_days = 90`
3. Add root outputs that expose both buckets' URLs.
4. Run `terraform apply` and confirm two buckets exist with different
   retention periods:
   ```bash
   gcloud storage buckets describe gs://YOUR_BUCKET_NAME --format="value(lifecycle)"
   ```

## Success criteria

- The module has no hardcoded bucket name, location, or retention —
  everything that differs between `logs` and `backups` comes from
  module inputs.
- Both buckets exist simultaneously without a naming collision.

## Discussion question

Nothing marks `modules/bucket_with_lifecycle/` as a module except
that you referenced it with `source = "./modules/bucket_with_lifecycle"`
somewhere. What does that tell you about what a Terraform module
actually *is* — is it a special kind of file, or just an ordinary
folder of resources used a particular way?
