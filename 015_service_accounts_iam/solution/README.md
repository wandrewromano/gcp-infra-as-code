# 015 — Solution: Service Accounts and IAM

## What this creates

- **`google_storage_bucket`** — something to scope permissions to.
- **`google_service_account.vm_runner`** — a dedicated identity for
  the VM.
- **`google_storage_bucket_iam_member`** — grants `vm_runner`
  `roles/storage.objectViewer`, **on that one bucket only**.
- A `google_compute_instance` (network/firewall from 008/010) running
  as `vm_runner` instead of the project's default Compute Engine
  service account.

## Why not just use the default service account

Every GCP project has a default Compute Engine service account, and
every VM uses it unless told otherwise. Historically that account
often ends up with broad project-level access (directly or via the
`Editor` role), which means: if that one VM is ever compromised,
whatever's running on it can potentially act on *anything* in the
project — not just the bucket it actually needs. Creating a
purpose-built service account with exactly one role, on exactly one
resource, means a compromised VM's blast radius is one bucket, read
only. This is the core idea of least-privilege IAM, made concrete.

## Why `google_storage_bucket_iam_member` instead of `google_project_iam_member`

Both exist, and it's easy to reach for the project-level one because
it's more familiar. The difference is scope: a project-level binding
grants the role on *every* bucket in the project (including ones that
don't exist yet); a bucket-level binding grants it on exactly the one
bucket you named. Default to resource-level IAM whenever the access
need is actually resource-specific — which, in practice, is most of
the time.

## Things worth noticing

- **Scopes vs. IAM roles** — the VM's `scopes = ["cloud-platform"]`
  and the IAM role granted above are doing two different jobs. The
  scope is a ceiling on what *categories* of API access the VM's
  metadata server will ever hand out a token for; the IAM role is
  what's actually permitted within that ceiling. `cloud-platform` is
  the broad, modern scope — you're meant to do your actual
  restricting with IAM roles (like this exercise does), not narrower
  legacy scopes.
- If you forget the IAM binding entirely, the VM will still boot
  fine — the failure only shows up later, as an access-denied error
  the first time something running on the VM tries to touch the
  bucket. Least-privilege mistakes are often silent until used.
