# 012 — Solution: Dynamic Blocks

## What this creates

- The network/subnet pattern from
  [008_create_vpc_network](../../008_create_vpc_network).
- **One** `google_compute_firewall` rule with two `allow` entries,
  generated from `var.allowed_ports` via a `dynamic` block.
  `source_ranges` is a fixed value here — no conditional, that's
  [011_conditionals](../../011_conditionals)'s concept, not this one.

## Why dynamic blocks

`allow { }` is a *nested block*, not an argument — you can't build it
with a plain `for` expression the way you would a list or map value.
`dynamic "allow"` is what lets you generate nested blocks from a
collection: for each item in `var.allowed_ports`, it stamps out one
`allow { }` block using `allow.value` to reference that item's
fields. Without it, adding a third port range to `allowed_ports`
would mean going back into the resource and hand-adding a third
`allow { }` block to match — exactly the kind of code/data
duplication `for_each` on a resource avoids for whole resources, and
`dynamic` avoids for blocks *within* one resource.

## Things worth noticing

- Inside `dynamic "allow" { ... }`, the loop variable is named
  `allow` (matching the block label) unless you rename it with
  `iterator`. `allow.value` refers to the current item from
  `var.allowed_ports`; `allow.key` would be its index (or map key, if
  iterating a map instead of a list).
- This resource has no `target_tags`, unlike
  [010_firewall_rules](../../010_firewall_rules) — a deliberate
  simplification for this exercise (fewer moving parts, to keep focus
  on `dynamic`) versus what you'd want in a real rule.
- [011_conditionals](../../011_conditionals) wrote the same two `allow`
  blocks by hand. Compare the two resources side by side: the
  resource block here never changes when `allowed_ports` grows, while
  011's would need a new `allow { }` added by hand for every new
  port. That's the entire value of `dynamic` in one comparison.
