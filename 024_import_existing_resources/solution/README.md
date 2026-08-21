# 024 — Solution: Migrating Existing Resources

## What this creates

- Nothing new in GCP — the bucket already existed (you created it by
  hand in step 1). What this configuration does is bring it **under
  Terraform's management**: an `import` block in `imports.tf`, and a
  `google_storage_bucket.imported` resource block in `main.tf` that
  matches what's actually there.

## Why this matters

Every exercise so far started from nothing — Terraform created the
resource, so of course Terraform's state matches reality. Real
infrastructure is rarely that clean: things get created by hand
during an incident, by a different tool, by someone who left the
team, or from before your project adopted Terraform at all. Migrating
existing infrastructure into Terraform — without destroying and
recreating it — is a distinct, necessary skill, separate from
writing new resources from scratch.

## Why generate the config instead of writing it by hand

The classic approach (`terraform import <address> <id>`) only writes
to *state* — you still have to hand-write a resource block yourself
first, and if it doesn't match reality closely enough, your very next
`plan` shows a pile of "drift" that isn't really drift, it's just
your best guess being wrong. `-generate-config-out` flips that: the
provider reads the real resource and writes the config for you, so
the starting point is guaranteed accurate. You still read and clean
it up — generated code is a draft, not gospel — but you're editing
from something correct instead of guessing from scratch.

## Things worth noticing

- **The generated `location` came back as `"US-CENTRAL1"` (uppercase)**
  even though the `gcloud` command used lowercase. This is the
  provider reporting what the API actually returns, not what you
  typed — a small, realistic example of why you review generated
  config instead of trusting it blindly.
- **`force_destroy` doesn't appear at all.** It's a Terraform-only
  convenience attribute with no real GCP equivalent, so there's
  nothing for the provider to read back — it silently defaults to
  `false`. If you want it `true` (as most exercises in this course
  set it, for easy cleanup), you have to add it yourself; generation
  can't infer intent, only observed state.
- The `import` block is safe to leave in place after the import
  succeeds — re-running `terraform plan` with it present is a no-op
  once the resource is already in state, since there's nothing left
  to import. Some teams remove it once the import is confirmed;
  others leave it as a record of where the resource came from.
- **`clickops_resource = "true"` shows up in the generated config**
  because it was a real label on the real bucket when you created it
  by hand — generation doesn't know *why* a label exists, only that
  it does. Once the bucket is imported and Terraform-managed, that
  label has done its job (flagging this as something created outside
  Terraform); keeping it or removing it in a follow-up change is a
  judgment call, not something this exercise requires either way.
- This exercise and [021_configuration_drift](../../021_configuration_drift)
  are the same underlying idea from opposite directions: drift is
  "a *managed* resource that reality disagreed with," import is
  "a real resource that was never managed in the first place."
