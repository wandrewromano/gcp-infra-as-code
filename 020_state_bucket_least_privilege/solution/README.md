# 020 — Solution: Least-Privilege Access to the State Bucket

## What this creates

- **`google_service_account.state_runner`** — a dedicated identity
  standing in for "whatever runs `terraform apply`" in a real setup,
  distinct from your own account.
- **`google_storage_bucket_iam_member.state_runner_object_admin`** —
  grants `state_runner` `roles/storage.objectAdmin` on the state
  bucket **only**, not `roles/storage.admin`, not project-wide.
- **`google_storage_bucket_iam_member.human_reader`** — grants your
  own user `roles/storage.objectViewer` on the same bucket: read-only,
  no write access at all.

## Why a dedicated identity, when it's still you running `apply`

Every exercise so far has run as your own `gcloud auth` login. In a
real pipeline, the identity that runs `terraform apply` day to day is
its own service account — belonging to whatever CI system does the
running (GitHub Actions, GitLab CI, and similar — see the task
README's "What's a CI pipeline" section if you skipped it) — not any
individual engineer's account, precisely so its permissions can be
scoped and audited independently of whoever happens to trigger a run.
`state_runner` makes that distinction concrete: even though you're the
one applying this config, the *bucket's* IAM policy only names
`state_runner`, not you. Nothing in this exercise actually runs as
`state_runner` — no VM, no pipeline — it exists purely to be scoped
and inspected, standing in for an identity this course has no real
version of.

## Why `roles/storage.objectAdmin`, and why not `roles/storage.admin`

`objectAdmin` covers everything `state_runner` actually needs — read,
write, overwrite, delete individual objects (the state file, across
however many times you `apply`). `roles/storage.admin` covers all of
that *plus* `storage.buckets.setIamPolicy` — the permission to change
who else has access to the bucket, including granting itself more.
Reaching for the broader role because the name sounds right ("admin"
for something in the "state" pipeline) is the exact anti-pattern
[015_service_accounts_iam](../015_service_accounts_iam) already
pushed back on — the fix here is the same: name the specific
permissions actually needed, not the impressive-sounding bundle.

## Why a second, weaker binding for your own user

`state_runner` and "a human checking on state" are different roles
with different needs, even though in this course they're both,
practically speaking, you. Granting your own user
`roles/storage.objectViewer` instead of just relying on your
project-level access models the same discipline for *people* that
`state_runner` models for automation: scope each identity to what its
role actually requires, read-only where read-only is enough, rather
than one binding "because you're probably fine to access it anyway."

## Things worth noticing

- `gcloud storage buckets get-iam-policy` in README.md step 6 checks
  the bucket's policy from *outside* Terraform — a useful habit
  whenever you want to confirm what a config actually did, rather
  than what you believe it did from reading the HCL.
- `state_runner`'s own bindings were themselves created by a
  `terraform apply` you ran as yourself — this exercise doesn't
  attempt to solve who's allowed to change `state_runner`'s
  permissions going forward, only to establish the scoped boundary
  that question is really about. See the discussion question.
- This is the same idea as
  [015_service_accounts_iam](../015_service_accounts_iam)'s
  `vm_runner`: scope a service account to exactly the one resource and
  exactly the one capability it needs.
