# 011 — Solution: Conditional Expressions

## What this creates

- The network/subnet pattern from
  [008_create_vpc_network](../../008_create_vpc_network).
- **One** `google_compute_firewall` rule with two hardcoded `allow`
  blocks, and `source_ranges` chosen by a conditional expression on
  `var.environment`.

## Why the conditional instead of two separate resources

```hcl
source_ranges = var.environment == "prod" ? ["35.235.240.0/20"] : ["0.0.0.0/0"]
```

This is the same underlying idea as
[010_firewall_rules](../../010_firewall_rules)'s IAP-only SSH rule, made
data-driven: instead of two separate hardcoded firewall resources
(one loose for dev, one strict for prod), one resource's behavior
changes based on an input. The ternary (`condition ? a : b`) is the
simplest form of conditional logic in Terraform — reach for it when a
single value needs to differ based on something else, before reaching
for `count = condition ? 1 : 0` (a much heavier tool, used to
conditionally create or omit an entire resource).

## Things worth noticing

- This resource has no `target_tags`, unlike
  [010_firewall_rules](../../010_firewall_rules) — worth noticing what's
  a deliberate simplification for this exercise (fewer moving parts,
  to keep focus on the conditional) versus what you'd want in a real
  rule.
- The conditional is evaluated at plan time, from the value of
  `var.environment` you pass in — nothing here reacts automatically
  if some *other* condition changes later. Terraform conditionals
  aren't runtime logic; they're resolved once, per `plan`/`apply`.
- The two `allow` blocks here are hardcoded, on purpose — this
  exercise is scoped to conditionals alone. Generating blocks like
  these from a list instead of writing each by hand is its own
  concept, covered next in
  [012_dynamic_blocks](../../012_dynamic_blocks).
