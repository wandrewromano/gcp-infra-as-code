# 026 (Part 1) — Build an Image with Packer

**Goal:** build a custom GCP machine image with Packer — install
software once, at image-**build** time, instead of every VM **boot**.

[Visit the Official Packer googlecompute Builder Documentation Here](https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute)

[Visit the Official Packer Install Documentation Here](https://developer.hashicorp.com/packer/install)

## Why bake software into an image instead of a startup script

[013_create_vm](../../../013_create_vm) and
[014_templatefile_startup_script](../../../014_templatefile_startup_script)
install Apache with a startup script — a shell script that runs every
time the VM boots. That works, but it means every boot depends on
`apt-get` actually succeeding, over the network, before the VM is
useful; a slow mirror or a bad rollout of a package version changes
your VM without you touching any code.

**Packer** takes a different approach: it boots a *temporary* VM, runs
your install steps once, snapshots the result as a reusable **image**,
then tears the temporary VM down. Any VM built from that image already
has Apache installed the instant it boots — no startup script, no
`apt-get`, no network dependency at boot time. This is sometimes called
"baking" (Packer, here) vs. "frying" (a startup script, in 013/014) —
same end result, different point in time where the work happens.

Packer is a **separate tool** from Terraform — its own binary, its own
`packer build` command — but it uses the same HCL language you already
know, and `packer { required_plugins { ... } }` is structurally the
same idea as Terraform's `terraform { required_providers { ... } }`.
It also authenticates to GCP the same way Terraform's `google`
provider does — the `gcloud auth application-default login` you ran
back in [000_start_here](../../../000_start_here) already covers this;
there's no new auth setup here.

## Setup

1. Install Packer if you haven't already — see the official install
   docs linked above (`brew install packer` on macOS).
2. `app-server.auto.pkrvars.hcl` already exists, committed with a
   placeholder — edit `project_id` to your real project ID. Packer
   loads any `*.auto.pkrvars.hcl` file automatically, the same way
   Terraform auto-loads `terraform.tfvars`.

## Tasks

1. Fill in `app-server.pkr.hcl`'s `packer` block, requiring the
   `googlecompute` plugin.
2. Declare `variable "project_id"`.
3. Define `source "googlecompute" "app_server"` — the base image to
   start from (`debian-12`, same as 013), the zone to build in, and
   two names: `image_name` (unique per build, via `{{timestamp}}` —
   Packer's own templating syntax, not Terraform's `${...}`) and
   `image_family` (a stable label — see the discussion question).
4. Define a `build` block using that source, with a `shell`
   provisioner that installs `apache2` — the same package 013's
   startup script installs, so the only new idea here is *when* it
   installs, not *what*.
5. Download the plugin and initialize:
   ```bash
   packer init app-server.pkr.hcl
   ```
6. Build the image:
   ```bash
   packer build app-server.pkr.hcl
   ```
   This takes a few minutes — Packer boots a real temporary VM, SSHes
   into it, runs your provisioner, snapshots it as an image, then
   deletes the temporary VM. Slower than a single `terraform apply`,
   because it's doing more.
7. Confirm the image exists:
   ```bash
   gcloud compute images list --filter="family=app-server"
   ```

## Success criteria

`gcloud compute images list --filter="family=app-server"` shows an
image you built, and its creation timestamp matches when you ran
`packer build`.

## Cleanup

Unlike everything else in this course, this image isn't Terraform-
managed — nothing will `destroy` it for you, and GCP charges a small
amount for image storage. When you're done with Part 2 as well, delete
it by hand:
```bash
gcloud compute images list --filter="family=app-server" --format="value(name)"
gcloud compute images delete YOUR_IMAGE_NAME
```

## Discussion question

`image_name` is unique per build (`{{timestamp}}` guarantees that);
`image_family` is the same fixed string (`app-server`) every time you
rebuild. [Part 2](../../part2_use_image) will reference the image by
family, not by exact name. Why does a *consumer* of this image (like a
Terraform config creating VMs from it) want to reference "whatever the
latest image in this family is," rather than one specific, frozen
image name?
