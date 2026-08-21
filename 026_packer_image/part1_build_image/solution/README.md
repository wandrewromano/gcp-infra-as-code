# 026 (Part 1) — Solution: Build an Image with Packer

## What this creates

- A custom GCP machine image, `app-server-<timestamp>`, in the
  `app-server` image family — Debian 12 with Apache pre-installed.
- Nothing Terraform-managed — this whole part uses only Packer.

## Why `packer { required_plugins { ... } }`

Packer's provider-equivalents are called **plugins**, and like
Terraform providers, they're not bundled with the core binary — the
`googlecompute` plugin (everything needed to talk to GCP's Compute
Engine API) has to be declared and downloaded separately via
`packer init`, mirroring `terraform init` downloading the `google`
provider. Same problem (don't bundle every cloud's SDK into one
binary), same solution shape, different tool.

## Why a `shell` provisioner instead of a startup script

A **provisioner** is Packer's term for "a step that configures the
temporary build VM before it gets snapshotted." `shell` with `inline`
runs a list of commands over SSH, in order — the simplest provisioner
type, and enough for one package. Packer also supports more elaborate
provisioners (`ansible`, `puppet`, uploading files, etc.) for more
complex builds, but `shell` covers the exact same ground 013's startup
script did, which is the point: same install steps, different point
in time.

## Why `image_family` in addition to `image_name`

`image_name` (`app-server-{{timestamp}}`) has to be unique per build —
GCP won't let you create two images with the same name, and Packer's
own templating (`{{timestamp}}`, evaluated by Packer itself, not
Terraform) guarantees that. `image_family` (`app-server`, fixed) is
what [Part 2](../../part2_use_image) actually references: GCP resolves
"give me the latest image in family X" automatically, so a consumer
never needs to know or update an exact image name — rebuild the image
as many times as you want, and anything referencing the family picks
up the newest one without any change on the consuming side.

## Things worth noticing

- `packer build` takes several minutes because it's doing real work: 
  boot a temporary VM, wait for SSH to become reachable, run the
  provisioner, stop the VM, snapshot its disk as an image, delete the
  temporary VM. Compare that to `terraform apply` on a single VM
  resource, which just asks the API to create one thing and returns.
- The temporary build VM is not the same VM [Part 2](../../part2_use_image)
  creates — it's scaffolding Packer throws away once the image exists.
  If a build fails partway, check `gcloud compute instances list` for
  a leftover `packer-*` VM Packer didn't get to clean up.
- This image isn't Terraform-managed and never will be — `packer
  build` is the only thing that creates or updates it. Part 2's
  Terraform config only *references* it, the same way a `data` source
  reads something Terraform doesn't own.
