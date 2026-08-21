# 023 — Solution: terraform state mv / rm

## What this creates

- One `google_storage_bucket`, named `legacy` in code initially, and
  `renamed` by the end — the same real bucket throughout. The
  interesting part isn't the final `main.tf`, it's the sequence of
  `terraform state` commands that got there.

## Why renaming a resource in code is riskier than it looks

Terraform identifies every real-world object by its **resource
address** (`google_storage_bucket.legacy`), not by anything about the
object itself. Change the label in code from `legacy` to `renamed`
with nothing else different, and as far as Terraform's state file is
concerned, `google_storage_bucket.legacy` no longer exists in your
config and `google_storage_bucket.renamed` is a resource it's never
seen before. The plan it produces — destroy one, create the other —
is Terraform behaving exactly as designed; it has no way to know
you meant "the same bucket, new name" instead of "delete this one,
make an unrelated one."

## Why `terraform state mv` fixes it

```bash
terraform state mv google_storage_bucket.legacy google_storage_bucket.renamed
```

This edits *only* the state file — it relabels the existing entry
without touching GCP at all. Once state agrees the address is now
`renamed`, `terraform plan` compares your code (`renamed`) against
state (also now `renamed`) and finds no difference, because there
isn't one. This is the general pattern any time you refactor
addresses in code — renaming a resource, moving one into or out of a
module — `state mv` first, so the state file catches up to the
rename before Terraform ever compares it to reality.

## Why `terraform state rm` is a different kind of operation

`state rm` deletes an entry from state **without** touching the real
resource — the opposite direction from `import`. Immediately after
running it, your code still declares `google_storage_bucket.renamed`,
but state has no record of it — so `terraform plan` proposes to
*create* it, exactly as if it had never existed. Had you actually run
`apply` at that point, GCP would have rejected the create (bucket
names are unique — yours already exists), producing a confusing
"already exists" error that has nothing to do with your config being
wrong. This is why the exercise has you stop and look at the plan
instead of applying it.

## Things worth noticing

- All three commands here — `state mv`, `state rm`, and classic
  `terraform import` — only ever touch the **state file**. None of
  them create, modify, or destroy anything in GCP. That's exactly why
  they're the right tools for "my code and reality both describe the
  same thing correctly, but Terraform's bookkeeping disagrees" —
  which is a different problem than "reality needs to change to match
  my code" (`apply`) or "my code needs to change to match reality"
  ([021_configuration_drift](../021_configuration_drift)).
- `terraform state list` is worth running after each step here — it's
  the most direct way to see exactly what Terraform currently
  believes it manages, independent of what your `.tf` files say.
- This exercise and
  [024_import_existing_resources](../024_import_existing_resources)
  both end with `terraform import`, but for different reasons: there,
  the resource was *never* managed; here, it was un-managed on
  purpose (via `state rm`) and then re-managed, as a way to see both
  directions of the state boundary using one resource.
