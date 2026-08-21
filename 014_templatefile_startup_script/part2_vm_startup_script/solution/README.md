# 014 (Part 2) — Solution: templatefile() for a Startup Script

## What this creates

- The VM/network/firewall pattern from
  [013_create_vm](../../../013_create_vm), with one change:
  `metadata_startup_script` is rendered from
  `templates/startup.sh.tftpl` via `templatefile()` instead of an
  inline heredoc — the same function [Part 1](../../part1_render_output)
  used, now wired into a real resource instead of an `output`.

## Why templatefile() instead of a heredoc

`013_create_vm`'s heredoc works fine for a short, static script. It
stops working well the moment the script needs to vary — different
packages per environment, a value that comes from a variable, a
script long enough that burying it inside a resource block hurts
readability. `templatefile()` separates "the script" (a file you can
syntax-highlight, lint, and read on its own) from "the values that
fill it in" (an ordinary Terraform map) — the same separation of
concerns `variables.tf` gives you for the rest of your config.

## Why not use a real provisioner instead

Terraform has `remote-exec`/`local-exec` provisioners that can run
commands against a resource after creation. They're generally
discouraged for exactly this use case: provisioners run outside
Terraform's model of "compare desired state to reality," so Terraform
can't reliably know if they succeeded, retry them safely, or account
for them in `plan`. A startup script passed as VM metadata is
GCP-native, idempotent from Terraform's point of view (it's just a
string value on the resource), and re-runs are the guest OS's
responsibility, not Terraform's.

## Things worth noticing

- `templatefile()` runs **on your machine, at plan time** — by the
  time `metadata_startup_script` reaches GCP, it's already a fully
  rendered string. The VM never has access to the `.tftpl` file
  itself.
- The `.tftpl` extension is a convention, not a requirement — but
  it's worth following, since it signals "this file uses Terraform
  template interpolation" to both humans and editor tooling.
- **Changing `welcome_message` and re-`apply`ing against an
  already-running VM does not update its web page.** The startup
  script only runs on first boot (or an explicit restart) — Terraform
  updates the VM's `metadata_startup_script` attribute, which is a
  real, detectable change, but nothing on the running instance
  re-executes it automatically. You'd need to reset the VM
  (`gcloud compute instances reset`) to see the new script run. This
  is a common surprise: the *config* being correct and *applied*
  doesn't always mean the *running system* reflects it yet.
- Contrast this with [Part 1](../../part1_render_output), where the same
  kind of variable change showed up the instant you reran `apply`.
  The function isn't what changed — `templatefile()` still renders at
  plan time in both cases. What changed is where the rendered value
  goes: an `output` has no separate running system to fall out of
  sync with, but a VM's boot process does.
