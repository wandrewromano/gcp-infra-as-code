# 026 (Part 2) — Deploy a VM from Your Packer Image

**Goal:** create a VM from the image [Part 1](../../part1_build_image)
built, instead of a stock image plus a startup script — and see the
actual payoff of "baking" software in ahead of time.

[Visit the Official google_compute_instance Resource Documentation Here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)

## Setup

`variables.tf` already has `project_id`/`region` pre-filled — that
part goes back to [003_variables_and_outputs](../../../003_variables_and_outputs).
`terraform.tfvars` is already here too, committed with placeholder
values — just edit `project_id` to your real project ID. You'll need
[Part 1](../../part1_build_image) done first — this exercise references
the image it built.

## Tasks

1. Rebuild the network, subnet, and firewall rules from
   [013_create_vm](../../../013_create_vm).
2. Define a `google_compute_instance`, same shape as 013's, with one
   change to the boot disk:
   ```hcl
   boot_disk {
     initialize_params {
       image = "projects/${var.project_id}/global/images/family/app-server"
     }
   }
   ```
   This is the same `image_family` you set in
   [Part 1](../../part1_build_image) — GCP resolves `family/app-server`
   to whatever the latest image in that family is, automatically.
3. Do **not** add a `metadata_startup_script`. There's nothing left
   for it to do — Apache is already installed in the image itself.
4. Add the same `vm_external_ip` output as 013's.
5. Run `terraform apply`.
6. As soon as the VM shows `RUNNING`
   (`gcloud compute instances describe example-vm --format="value(status)"`),
   `curl http://<external-ip>` — don't wait a minute the way 013 told
   you to. Compare how long this takes to become reachable versus 013.

## Success criteria

Apache's default page loads within a few seconds of the VM reporting
`RUNNING` — no "give it a minute for the startup script" wait, because
there's no startup script.

## Discussion question

013/014 install Apache with a startup script that runs on every boot;
this exercise installs it once, when the image was built. This split —
sometimes called "baking" (image-build time) vs. "frying" (boot time)
— is a real, ongoing tradeoff in infrastructure design, not something
with one right answer. What did you give up by moving the install to
image-build time? (Consider: what happens when a security patch for
Apache ships — which approach picks it up sooner, and what has to
happen for the other one to catch up?)
