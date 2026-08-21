# 003 — Variables and Outputs

**Goal:** stop hardcoding values. Parameterize the bucket from
exercise 002 with variables, and expose useful values as outputs.

[Visit the Official Terraform Input Variables Documentation Here](https://developer.hashicorp.com/terraform/language/values/variables)

[Visit the Official Terraform Output Values Documentation Here](https://developer.hashicorp.com/terraform/language/values/outputs)

`variables.tf` and `outputs.tf` already exist in this folder with
commented-out `TODO` skeletons — this is the first time you're
writing `variable` and `output` blocks yourself, so the shape is
given; uncomment each one and fill in the blanks.

## Tasks

1. In `variables.tf`, fill in:
   - `project_id` (string, no default — must be supplied)
   - `region` (string, default `"us-central1"`)
   - `bucket_name` (string, no default)
2. Update `main.tf` to reference `var.project_id`, `var.region`, and
   `var.bucket_name` instead of hardcoded values.
3. Create a `terraform.tfvars` in this folder with your actual
   values, e.g.:
   ```
   project_id  = "your-real-project-id"
   region      = "us-central1"
   bucket_name = "your-real-project-id-exercise-003"
   ```
   Commit it once you've created it, same as any other file in this
   folder — see "Why we're committing terraform.tfvars" below.
4. In `outputs.tf`, fill in:
   - `bucket_url` — the bucket's `gs://` URL
   - `bucket_self_link` — its **self link**: the full HTTPS URL to
     this exact resource in the GCP API. Most GCP resource types
     expose one; it's mainly useful for pointing *other* resources or
     API calls at this one unambiguously, rather than something
     you'd visit in a browser like the console URL.
5. Run `terraform apply` and confirm both outputs print correctly.

## Success criteria

Running `terraform apply -var="bucket_name=something-else"` (without
editing any `.tf` files) changes which bucket gets created — proof
the configuration is fully parameterized.

## Why we're committing terraform.tfvars

Terraform automatically loads a file named exactly `terraform.tfvars`
on every `plan`/`apply` — no flag needed. It's tempting to assume a
file like this should always be gitignored, but that's not quite
right: `project_id`, `region`, and `bucket_name` aren't secrets —
they're ordinary config, no different from anything else in `main.tf`.
Hiding them buys you nothing and just adds ceremony (a separate
template file, a copy step, remembering what's gitignored). So in
this course, `terraform.tfvars` is committed like any other file,
starting here.

That's not true of every value you'll meet, though.
[016_secret_manager](../../016_secret_manager) introduces a genuinely
sensitive value, and treats it completely differently — not just kept
out of `terraform.tfvars`, but kept out of Terraform *entirely*: it
never becomes a `variable` at all, because anything that does becomes
a value Terraform writes to its own state file, sensitive or not.
That contrast is the actual lesson: most config is fine to commit as
a plain Terraform variable; a real secret doesn't belong to Terraform
as a value in the first place — it's supplied directly to the system
that stores it (in practice, a secrets vault or CI injection step),
not "put it in a file nobody's supposed to look at," and not "pass it
to Terraform more carefully" either.

## Hints

- Variables without a `default` are required inputs — Terraform will
  prompt for them interactively if not supplied via `.tfvars` or
  `-var`.
- `terraform output <name>` prints a single output after apply.
