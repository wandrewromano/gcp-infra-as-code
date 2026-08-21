# 010 — Solution: Firewall Rules

## What this creates

- The network/subnet from exercise 008, plus:
- **`google_compute_firewall.allow_ssh_iap`** — SSH, only from
  `35.235.240.0/20`, only on instances tagged `ssh`.
- **`google_compute_firewall.allow_http`** — HTTP, from anywhere,
  only on instances tagged `http-server`.

## Why

GCP VPC firewalls are **implicit deny**: unless a rule explicitly
allows traffic, it's blocked, in both directions, for every instance
in the network. That surprises people coming from environments where
"everything's open until you lock it down" is the default. These two
rules exist to make that visible, and to demonstrate the two axes you
scope a rule on:

- **`source_ranges`** — *where* traffic is allowed from.
- **`target_tags`** — *which instances* the rule applies to.

## Why `35.235.240.0/20` specifically

That range belongs to Google's **Identity-Aware Proxy (IAP)**. IAP
lets you SSH into a VM through an encrypted tunnel proxied by Google,
authenticated by your IAM identity — the VM never needs a public IP
with port 22 open to the internet at all. Restricting the SSH rule's
source to that range (instead of `0.0.0.0/0`) means even if someone
finds your VM's IP, they can't reach port 22 directly — they'd need
valid Google Cloud IAM credentials and to go through the tunnel. This
is meaningfully different from "a strong password on an open port,"
which is the mistake this rule is designed to make hard to make.

## Things worth noticing

- Nothing enforces that a VM using these rules is actually tagged —
  tags are just labels. If you create a VM in exercise 013 and forget
  the `tags` attribute, these rules simply won't apply to it (which
  usually means you can't reach it at all — that's the fail-safe
  direction to err on).
- The HTTP rule is intentionally open (`0.0.0.0/0`) because a web
  server is, by definition, meant to be reachable from anywhere. Not
  every rule should be locked down the way the SSH one is — the
  point is scoping each rule to what it's actually for.
