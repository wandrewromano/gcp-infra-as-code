# 003 — Solution: Variables and Outputs

## What this creates

- The same `google_storage_bucket` from exercise 002, but every value
  that previously was hardcoded (`project_id`, `region`,
  `bucket_name`) is now a `variable`, supplied via `terraform.tfvars`.
- Two outputs: `bucket_url` and `bucket_self_link`.

## Why variables

Hardcoded values mean the only way to reuse a configuration is to
copy-paste it and hand-edit the copy — which is exactly what doesn't
scale past one person or one environment. Variables separate *what*
the configuration does from *which values* it runs with, so the same
`.tf` files can create a dev bucket, a staging bucket, or a
teammate's personal test bucket, all from one shared config.

- `project_id` and `bucket_name` have **no default** — they're
  required inputs. Terraform enforces you can't `apply` without
  supplying them, which is the right behavior for anything
  environment-specific (you never want a "default" project ID that
  might silently point somewhere real).
- `region` **has a default** — it's the kind of value that's usually
  fine left alone, but still worth being able to override.

## Why outputs

Outputs are how a configuration reports values back out — either to
a human running `terraform apply` (so they don't have to go find the
bucket URL by hand), or to another system (`terraform output -json`
is commonly piped into scripts, CI/CD pipelines, or other Terraform
configs that need to reference what this one created).

## Things worth noticing

- Terraform resolves variables in this precedence order (highest
  wins): `-var` / `-var-file` flags, `terraform.tfvars`,
  `*.auto.tfvars`, environment variables (`TF_VAR_*`), then the
  variable's `default`. Worth knowing once you're juggling more than
  one way to supply a value.
- `terraform.tfvars` is committed here, same as every other file —
  see the README's "Why we're committing terraform.tfvars" section.
  None of `project_id`/`region`/`bucket_name` are sensitive, so
  there's no reason to hide them.
  [016_secret_manager](../../016_secret_manager) is where a value
  that actually needs hiding shows up, and it's handled completely
  differently — it never becomes a Terraform variable at all, not
  even a `sensitive` one.
