# 014 (Part 1) — Solution: Render a Template to Output

## What this creates

- No GCP resources — just a `terraform.tfvars`-driven `output` that
  renders `templates/welcome.tftpl` via `templatefile()`.

## Why no provider block

`templatefile()` and `output` are core Terraform language features,
not GCP-specific ones — nothing here needs to authenticate to
anything. That's deliberate: it isolates the one new idea (render a
file with variables) from every other exercise's `provider "google"`
boilerplate, so there's nothing to debug except the function itself.

## Things worth noticing

- `templatefile()`'s second argument is an ordinary Terraform map —
  `{ name = var.your_name }` — matched against the `${name}` blank in
  the template file. Add a second blank to the template and a second
  key to that map, and it works the same way; the function doesn't
  care how many.
- Re-running `apply` after changing `your_name` re-renders the output
  immediately, because `templatefile()` runs at plan time, and an
  `output` has nothing else to go stale — there's no separate running
  system for the rendered value to be copied onto. Keep this in mind
  for [Part 2](../../part2_vm_startup_script), where that's no longer
  true.
