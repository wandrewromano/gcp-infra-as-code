# 010 — Firewall Rules

**Goal:** practice least-privilege network design with
`google_compute_firewall`.

[Visit the Official google_compute_firewall Resource Documentation Here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall)

## What's a firewall rule, and what's IAP?

A VPC (see [008](../008_create_vpc_network)) denies all network
traffic by default — a **firewall rule** is how you explicitly punch
a hole in that: "allow traffic on this port, from this source, to
instances tagged like this." Each rule you'll write here has three
parts: which port/protocol it opens (`allow { protocol = "tcp",
ports = [...] }`), which source IP range is allowed to reach it
(`source_ranges`), and which instances it applies to (`target_tags` —
you'll tag a VM with a matching tag starting in
[013_create_vm](../013_create_vm) for these rules to actually do
anything yet).

Port 22 is SSH — the protocol used to get a remote terminal on a
Linux VM. Port 80 is plain HTTP — the protocol a web browser uses. If
you opened port 22 to `0.0.0.0/0` (the whole internet), every
automated scanner on the planet would start trying to log into your
VM within minutes; that's real, not theoretical.

**IAP (Identity-Aware Proxy)** is GCP's answer to that problem: instead
of exposing SSH to the internet at all, you leave it closed to
everyone *except* `35.235.240.0/20` — a fixed IP range that belongs to
Google's own IAP infrastructure — and connect through
`gcloud compute ssh --tunnel-through-iap` (you'll use this in
[013_create_vm](../013_create_vm)). GCP proxies the connection and
checks your IAM permissions before it ever reaches your VM, so you get
SSH access without ever putting port 22 on the open internet.

## Setup

`variables.tf` already has `project_id`/`region` pre-filled — that
part goes back to [003_variables_and_outputs](../003_variables_and_outputs).
`terraform.tfvars` is already here too, committed with placeholder
values — just edit `project_id` to your real project ID (see 003's
README for why this file is committed instead of gitignored).

## Tasks

1. Reuse the network from exercise 008 (copy it into this folder or
   rebuild it here).
2. Add a firewall rule that allows SSH (port 22) **only** from
   Google's Identity-Aware Proxy range: `35.235.240.0/20`. Use
   `target_tags` so it only applies to instances you explicitly tag.
3. Add a second firewall rule allowing HTTP (port 80) from
   `0.0.0.0/0`, also scoped with `target_tags`.
4. Run `terraform apply` and inspect the rules:
   ```bash
   gcloud compute firewall-rules list --format="table(name,sourceRanges.list(),allowed[].map().firewall_rule().list())"
   ```

## Success criteria

Two firewall rules exist, each scoped by tag rather than applying to
every instance in the network, and the SSH rule's source range is
restricted to the IAP range rather than the open internet.

## Discussion question

What would go wrong if you set `source_ranges = ["0.0.0.0/0"]` on the
SSH rule instead? Why does GCP's IAP range make that unnecessary?
