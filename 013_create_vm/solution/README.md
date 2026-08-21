# 013 — Solution: Deploy a VM

## What this creates

- The network, subnet, and firewall rules from 008/010.
- **`google_compute_instance`** — an `e2-micro` Debian 12 VM, tagged
  `["ssh", "http-server"]`, with a startup script that installs and
  starts Apache.

## Why these choices

- **`e2-micro`** — the smallest general-purpose machine type, and
  eligible for GCP's Always Free tier in `us-central1`, `us-west1`,
  and `us-east1`. Picking it here means you can experiment freely
  without worrying about cost, as long as you stay in one of those
  regions and remember to `terraform destroy` when done.
- **`metadata_startup_script`** — runs once, on first boot, as root.
  This is the bridge between infrastructure-as-code (Terraform
  deciding *what exists*) and configuration-as-code (a script
  deciding *what's installed on it*). In a real project you'd
  typically hand this off to something more structured (a custom
  image, or a config management tool), but for a single VM a startup
  script is the simplest way to get from "empty VM" to "running web
  server" in one `apply`.
- **`access_config {}`** (empty block) — this is what gives the
  instance an ephemeral public IP. Omitting the block entirely
  produces a VM with no public IP at all (private-only, reachable
  only from inside the VPC or via IAP) — a meaningful choice you'll
  make deliberately in real designs.

## Things worth noticing

- It takes a minute or two after `apply` finishes for the startup
  script to actually run and for Apache to come up — if
  `http://<external-ip>` doesn't respond immediately, that's normal,
  not a failure.
- SSH access here relies entirely on the IAP-scoped firewall rule
  from exercise 010 — there's no rule allowing SSH from the open
  internet, by design.
- **Cost note:** `e2-micro` is free-tier eligible under normal usage
  in the three regions above, but "free" isn't the same as "can't
  incur charges" (e.g. sustained heavy use, extra disks, or running
  outside those regions all cost money). Always `terraform destroy`
  when you're done with this exercise.
