# 021 — Solution: Configuration Drift

## What this creates

- **`google_storage_bucket.drift_demo`** — a bucket with one label,
  `environment = "dev"`. The label is the whole point: it's a value
  that's trivial to change out-of-band and trivial to see change
  back.

## Why this matters

Terraform's model is that your code is the **single source of
truth**, and `apply` makes reality match it — every time, not just
the first time. Anything that changes a Terraform-managed resource
outside of Terraform (a manual Console edit, another script, a
teammate running `gcloud` directly) creates **drift**: a gap between
what your code says should exist and what actually exists. `terraform
plan` is what surfaces that gap — it always compares real
infrastructure against your code, not against "whatever was there
last time."

## Walking through the two options

After manually setting the label to `prod` (and, per
[000_start_here](../../000_start_here) step 6, tagging the
change `clickops_resource=true` so it's identifiable as a manual
edit):

```
# terraform plan
  ~ resource "google_storage_bucket" "drift_demo" {
      ~ labels = {
          - "clickops_resource" = "true" -> null
          - "environment"       = "prod" -> null
          + "environment"       = "dev"
        }
    }
```

`clickops_resource` shows up in the diff too, and that's expected —
it's a label you added by hand and never declared in code, so
Terraform treats it exactly like the `environment` change: something
real that isn't in your config. It's there so you (or an instructor
scanning the project) can spot manually-touched resources, not
something meant to survive into the final, code-defined bucket.

- **`terraform apply`** does what apply always does: reconciles
  reality to match code. The label goes back to `dev`. This is the
  right call when the manual change was a mistake, unauthorized, or
  just not something you want to persist.
- **`terraform apply -refresh-only`** does something different: it
  updates Terraform's *state* to say "prod" (matching what's actually
  there) but does **not** touch the real bucket, and does **not**
  change your `.tf` files. Run `terraform plan` again right after,
  and you'll see the *exact same diff* as before — because your code
  still says `dev`, and now state agrees the real value is `prod`, so
  they still disagree.

That last point is the thing this exercise is really testing: refresh
only updates state, and does nothing to make your code and reality
agree — the code is still the thing being compared against. To
actually resolve the drift in code's favor, you'd edit `main.tf` to
say `prod` yourself (a deliberate, reviewable code change), not rely
on `-refresh-only` to do it for you.

## When `-refresh-only` is the right tool

Use it when the out-of-band change was *legitimate* and you want your
code to catch up to reality, but you want to review exactly what
changed before you decide how — for example, someone fixed an urgent
production issue by hand, and now you need to bring that fix into
version control deliberately, not have a routine `apply` silently
stomp it back to the old value. `-refresh-only` gives you a safe,
read-only way to see what drifted before deciding what to do about
it.

## Things worth noticing

- Every `terraform apply` implicitly refreshes state before planning
  — you didn't need a special flag to *detect* drift in step 4, only
  to update state *without* also correcting the real resource.
- This exercise reuses the same "state vs. reality" boundary that
  [024_import_existing_resources](../../024_import_existing_resources)
  deals with from the opposite direction: import is about bringing
  something real but *unmanaged* into Terraform; drift is about
  something already *managed* that reality quietly disagreed with.
