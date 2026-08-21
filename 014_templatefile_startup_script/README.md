# 014 — templatefile()

**Goal:** learn `templatefile()` — render a template file with
variables — first in isolation, then apply it to something real.

This exercise is split into two parts. Do them in order.

- **[Part 1 — Render a Template to Output](part1_render_output/task)**
  — see `templatefile()` work with no GCP resources involved at all:
  no VM, no waiting, no provider. A few seconds per iteration.
- **[Part 2 — templatefile() for a Startup Script](part2_vm_startup_script/task)**
  — apply that same function to a VM's startup script, reusing the
  network/VM pattern from [013_create_vm](../013_create_vm). This is
  the "why it's useful for something real" payoff, and its discussion
  question builds directly on what Part 1 showed you.

[Visit the Official Terraform templatefile() Function Documentation Here](https://developer.hashicorp.com/terraform/language/functions/templatefile)
