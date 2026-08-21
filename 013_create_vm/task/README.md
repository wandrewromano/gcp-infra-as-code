# 013 — Deploy a VM

**Goal:** bring networking (008/010) and compute together by
deploying a real VM with a startup script.

[Visit the Official google_compute_instance Resource Documentation Here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)

## What's a VM?

**Compute Engine** is GCP's virtual machine service — `google_compute_instance`
creates one VM: a full virtual computer with its own CPU, memory,
disk, and OS, running on Google's hardware. A few terms you'll hit in
this exercise:

- **`machine_type`** picks how much CPU/RAM the VM gets. `e2-micro`
  is the smallest, cheapest tier — plenty for this exercise, and
  eligible for GCP's [Always Free
  tier](https://cloud.google.com/free/docs/free-cloud-features#compute)
  (a fixed monthly allowance of certain resource types that's free
  even outside any trial, currently one `e2-micro` instance in the
  regions below) so this specific VM shouldn't cost anything under
  normal use.
- **Boot disk / image**: a VM needs a disk to boot from, and that
  disk starts as a copy of an **image** — a pre-built OS snapshot.
  `debian-cloud/debian-12` means the Debian 12 image published in
  Google's own `debian-cloud` project; every VM you create from it
  starts identical, then diverges as your startup script runs.
- **Public IP**: a VM's network interface gets a private, internal-only
  IP by default. Adding an empty `access_config {}` block requests an
  *ephemeral* public IP too — reachable from the internet, which is
  exactly what lets you `curl` or browse to it in step 4, and exactly
  why the firewall rules from [010](../010_firewall_rules) matter here.

## Setup

`variables.tf` already has `project_id`/`region` pre-filled — that
part goes back to [003_variables_and_outputs](../003_variables_and_outputs).
`terraform.tfvars` is already here too, committed with placeholder
values — just edit `project_id` to your real project ID (see 003's
README for why this file is committed instead of gitignored).

## Tasks

1. Rebuild (or copy in) the network, subnet, and firewall rules from
   008/010.
2. Define a `google_compute_instance`:
   - `machine_type = "e2-micro"` (Always Free tier eligible in
     `us-central1`, `us-west1`, `us-east1`)
   - boot disk image: `debian-cloud/debian-12`
   - attach it to your subnet, with an `access_config {}` block for a
     public IP
   - tag it `["ssh", "http-server"]` so the firewall rules apply
3. Add a `metadata_startup_script` that installs and starts a
   basic web server, e.g.:
   ```bash
   #!/bin/bash
   apt-get update
   apt-get install -y apache2
   ```
4. Run `terraform apply`, then visit `http://<external-ip>` in a
   browser — give the startup script a minute to run first.
5. SSH in via IAP to confirm access:
   ```bash
   gcloud compute ssh example-vm --zone=YOUR_ZONE --tunnel-through-iap
   ```

## Success criteria

You can reach the Apache default page over HTTP, and SSH in through
IAP (not a public SSH port).

## Cost note

`e2-micro` is free-tier eligible in the three regions above under
normal usage. Always run `terraform destroy` when you're done.
