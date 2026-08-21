# 018 — Solution: Build a Module

## What this creates

- `modules/bucket_with_lifecycle/` — a small module wrapping the
  bucket-with-retention pattern from
  [002_create_storage_bucket](../../002_create_storage_bucket) behind
  `name`, `location`, and `age_days` inputs.
- Two calls to it from the root: a `logs` bucket (14-day retention)
  and a `backups` bucket (90-day retention).

## Why this exercise exists before the capstone

[025_capstone_module](../../025_capstone_module) asks you to
modularize network + firewall + VM all at once, which is a lot to
take on for your first module. This exercise isolates the *only*
new idea — turning a resource block into a reusable, parameterized
unit — using a resource type (a bucket) you already understand well,
so the only new thing you're learning is modules themselves.

## Why a module here, instead of just calling the bucket resource twice with different names inline

You could — nothing stops you from writing two `google_storage_bucket`
blocks with different names and lifecycle ages directly in root
`main.tf`. The module pays off once the *shape* (versioning on,
uniform access, an age-based deletion rule) is something you want to
guarantee is consistent everywhere it's used, not just something that
happens to look similar today. Change the module once — say, adding
a `labels` variable — and both `logs` and `backups` get it. With two
inline blocks, you'd have to remember to change both, and any third
future bucket, too.

## Things worth noticing

- A module has no special marker file or manifest — `modules/bucket_with_lifecycle/`
  is a module purely because something referenced it with
  `source = "./modules/bucket_with_lifecycle"`. The same folder of
  `.tf` files, called directly instead, would just be an ordinary
  root configuration.
- `force_destroy = true` is set inside the module, not left as a
  variable — this module always wants that behavior regardless of
  caller, which is a legitimate design choice: not every difference
  between possible use cases needs to become an input.
- Module outputs (`bucket_url`, `bucket_name`) are only reachable one
  level up — the root's own `outputs.tf` has to explicitly forward
  `module.logs.bucket_url` for it to be visible to `terraform output`.
