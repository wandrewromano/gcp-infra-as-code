# 025 — Solution: Capstone — Build a Module

## What this creates

- A `modules/vm_with_network/` module — the network, subnet, firewall
  rule, and VM from exercises 008, 010, 013, generalized behind input
  variables.
- Two calls to that module from the root `main.tf` — `dev` and
  `staging` — each with its own `name_prefix` and `subnet_cidr`, so
  they don't collide.
- Root-level outputs (`dev_vm_external_ip`, `staging_vm_external_ip`)
  that reach into each module instance's own outputs.

## Why modules

Without a module, standing up a second identical-shaped environment
means copy-pasting the network/firewall/VM blocks and hand-editing
every name so nothing collides — and now there are two places to fix
every future change. A module turns that block of resources into a
single reusable unit with a defined interface (its `variables.tf` in,
its `outputs.tf` out). Change the module once, and every caller
benefits; each caller only needs to supply the handful of values that
actually differ between them.

## What moving to a module actually forces you to confront

The exercise isn't "put the same code in a subfolder" — it's
figuring out **which values would collide if this module is called
twice**, because those are exactly the ones that have to become
variables:

- Network and subnet names (`${var.name_prefix}-network`, etc.) —
  two networks named `example-network` in the same project would
  conflict outright.
- The subnet CIDR — two subnets with overlapping ranges in the same
  network can't coexist.
- The firewall rule name and its `target_tags` — tags need to be
  distinct per instance too, or `dev`'s firewall rule would
  inadvertently apply to `staging`'s VM.

Anything that *doesn't* vary between callers (the boot image, the
firewall protocol/port, the IAP source range) stays hardcoded inside
the module — turning genuinely fixed values into variables just adds
noise without adding flexibility.

## Things worth noticing

- `module.dev.vm_external_ip` is how you reach into a module
  instance's outputs from the root — a module's `output` blocks are
  only visible one level up, not automatically exposed further.
- This module still isn't quite "safe to reuse across a whole team" —
  see the discussion question in the task README. In particular:
  each `dev`/`staging` pair here still shares one Terraform state and
  one `apply`, which isn't how you'd want real environments to work
  (you'd typically give each its own state, e.g. via separate
  backends or a tool like Terragrunt/workspaces).
- No `depends_on` was needed between the two module calls — they're
  fully independent of each other, which is exactly what you want:
  changing `staging` should never require touching or risk affecting
  `dev`.
