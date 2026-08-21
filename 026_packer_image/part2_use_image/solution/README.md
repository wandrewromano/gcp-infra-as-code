# 026 (Part 2) — Solution: Deploy a VM from Your Packer Image

## What this creates

- The network/subnet/firewall pattern from
  [013_create_vm](../../../013_create_vm), with one change: the VM's
  boot disk image is `projects/${var.project_id}/global/images/family/app-server`
  — the image [Part 1](../../part1_build_image) built — instead of
  `debian-cloud/debian-12`.
- No `metadata_startup_script` — nothing left for it to do.

## Why `family/app-server` instead of a specific image name

GCP resolves `projects/PROJECT/global/images/family/FAMILY_NAME` to
whichever image in that family was created most recently, at the
moment this VM is created. If you go back and run `packer build` again
after a package update, this Terraform config doesn't change at all —
the next `terraform apply` (or the next time this instance is
recreated) picks up the newer image automatically, the same way
`family/debian-12` (which 013 uses under the hood, via
`debian-cloud/debian-12`) always points at the current Debian 12
release rather than one frozen snapshot.

## Things worth noticing

- This is the concrete payoff of [Part 1](../../part1_build_image)'s
  work: `curl` succeeds within a few seconds of `RUNNING`, because
  there's no `apt-get install` left to run at boot. Compare that
  directly against [013_create_vm](../../../013_create_vm), which asks
  you to "give it a minute."
- Terraform has no idea this image was built by Packer, and doesn't
  need to — it just reads `projects/.../images/family/app-server`
  through the `google` provider, the same way it'd read any other
  image reference. Packer and Terraform don't talk to each other
  directly; they both just talk to the GCP API, at different points in
  the pipeline.
- If [Part 1](../../part1_build_image)'s image doesn't exist yet (or
  its family name doesn't match), this `apply` fails with an image-not-
  found error — a real, useful example of one tool depending on
  another's output without any code-level integration between them.
