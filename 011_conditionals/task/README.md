# 011 — Conditional Expressions

**Goal:** pick a value based on a condition instead of hardcoding it.

[Visit the Official Terraform Conditional Expressions Documentation Here](https://developer.hashicorp.com/terraform/language/expressions/conditionals)

## Why a conditional, instead of two separate resources

Conditional expressions (`condition ? true_val : false_val`) solve a
narrow problem: picking one of two values for a single argument based
on some other value, without duplicating the whole resource block for
each case. Here, `source_ranges` needs to be the open internet in
`dev`/`staging` (so you can reach it while testing) but locked to the
IAP range in `prod` (see [010_firewall_rules](../../010_firewall_rules)
for why that matters). A conditional lets one resource block serve
both cases — the alternative would be two separate, hardcoded firewall
resources (one loose, one strict), which then also need to be kept in
sync by hand as the rest of the rule changes.

## Setup

`variables.tf` already has `project_id`/`region` pre-filled — that
part goes back to [003_variables_and_outputs](../../003_variables_and_outputs).
`terraform.tfvars` is already here too, committed with placeholder
values — just edit `project_id` to your real project ID (see 003's
README for why this file is committed instead of gitignored).

## Tasks

1. Reuse the network/subnet pattern from
   [008_create_vpc_network](../../008_create_vpc_network) /
   [010_firewall_rules](../../010_firewall_rules).
2. Define **one** `google_compute_firewall` resource with two
   hardcoded `allow` blocks, same as 010:
   ```hcl
   allow {
     protocol = "tcp"
     ports    = ["22"]
   }

   allow {
     protocol = "tcp"
     ports    = ["80", "443"]
   }
   ```
3. Bring forward the validated `environment` variable from
   [005_variable_validation](../../005_variable_validation) — string,
   default `"dev"`, with its `validation` block restricting it to
   `dev`/`staging`/`prod` — rather than declaring a fresh, unvalidated
   one. Set the firewall rule's `source_ranges` with a conditional
   expression: narrow to the IAP range (`35.235.240.0/20`) in
   `"prod"`, and `0.0.0.0/0` otherwise.
4. Run `terraform apply`, then confirm the rule's source range:
   ```bash
   gcloud compute firewall-rules describe YOUR_RULE_NAME --format="value(sourceRanges)"
   ```
5. Change `environment` to `"prod"` and run `terraform plan` — confirm
   only `source_ranges` changes.

## Success criteria

One firewall rule's `source_ranges` changes based on `var.environment`
without touching the resource block itself — `dev`/`staging` show
`0.0.0.0/0`, `prod` shows the IAP range.

## Discussion question

You just wrote two `allow { }` blocks by hand. What would make that
stop being simpler — at what number of ports, or under what kind of
change, would you reach for something other than adding a third block
by hand?
