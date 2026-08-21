# 012 — Dynamic Blocks

**Goal:** generate repeated nested blocks from a list instead of
writing each one by hand.

[Visit the Official Terraform Dynamic Blocks Documentation Here](https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks)

## Why a dynamic block

In [007_count_for_each](../../007_count_for_each) you used `for_each` to
generate multiple *resources* from one block. A `dynamic` block solves
the same problem one level deeper: generating multiple *nested
blocks* — like `allow { }` inside a single `google_compute_firewall`
resource — from a list, instead of writing one `allow { }` per port by
hand, the way [011_conditionals](../../011_conditionals) just did.
Without it, adding a port means editing the resource itself; with it,
adding a port means editing `var.allowed_ports`, and the resource
never changes. That distinction matters because the resource block is
the thing you review and diff carefully — the variable is the thing
you expect to change often.

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
2. Define a variable `allowed_ports`:
   ```hcl
   variable "allowed_ports" {
     type = list(object({
       protocol = string
       ports    = list(string)
     }))
     default = [
       { protocol = "tcp", ports = ["22"] },
       { protocol = "tcp", ports = ["80", "443"] },
     ]
   }
   ```
3. Define **one** `google_compute_firewall` resource with a
   `dynamic "allow"` block that generates one `allow { }` block per
   entry in `var.allowed_ports`:
   ```hcl
   dynamic "allow" {
     for_each = var.allowed_ports
     content {
       protocol = allow.value.protocol
       ports    = allow.value.ports
     }
   }
   ```
   Use a fixed `source_ranges = ["35.235.240.0/20"]` — the conditional
   from 011 isn't part of this exercise.
4. Run `terraform apply`, then confirm the rule has **two** allowed
   entries:
   ```bash
   gcloud compute firewall-rules describe YOUR_RULE_NAME --format="value(allowed)"
   ```
5. Add a third entry to `allowed_ports` in `terraform.tfvars` (or the
   variable's `default`) and run `terraform plan` — confirm the
   resource block itself needs no changes to pick it up.

## Success criteria

One firewall rule, generated from one resource block, has its `allow`
entries sourced entirely from `var.allowed_ports` — adding or removing
a port means editing the variable, never the resource.

## Discussion question

You could get the same `allow` entries by writing one `allow { }`
block per port directly in the resource, with no `dynamic` at all —
which is exactly what [011_conditionals](../../011_conditionals) did with
two blocks. At what point does hardcoding each block stop being
simpler than a `dynamic` block — and why does that threshold matter
less once the list comes from a variable instead of being fixed in
your head while you write the code?
