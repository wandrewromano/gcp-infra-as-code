# 002 — Solution: Your First Resource: a Storage Bucket

## What this creates

- **`google_storage_bucket`** — a Cloud Storage bucket, with
  versioning and a 30-day deletion lifecycle rule (the stretch goal).

## Why a bucket, specifically

Cloud Storage buckets are the standard "hello world" for a first real
resource, for practical reasons: they're effectively free at this
scale, they create and destroy in seconds (no multi-minute VM boot or
network propagation to wait through), and they don't drag in any
other concepts (networking, IAM, compute) you haven't learned yet. In
the real world, buckets show up everywhere — static website hosting,
storing Terraform state itself (see [019_remote_state](../../019_remote_state)),
data lake ingestion, backups, and build artifacts.

## Why these specific settings

- **`uniform_bucket_level_access = true`** — Google's recommended
  default. Without it, a bucket supports two overlapping permission
  systems at once (IAM *and* legacy per-object ACLs), which is a
  common source of "why can this person access this object" bugs.
  Uniform access means IAM is the only source of truth.
- **`location = "US"`** — a multi-region location. Multi-region costs
  slightly more than a single region but gives higher availability;
  for a real workload you'd generally pick a single region close to
  where the data is used.
- **`versioning` + `lifecycle_rule`** (stretch goal) — versioning
  keeps old copies of an object when it's overwritten or deleted,
  protecting against accidental data loss; the lifecycle rule then
  automatically deletes objects older than 30 days so versioning
  doesn't cause storage costs to grow forever. This pairing —
  versioning for safety, a lifecycle rule for cost control — is the
  standard way to run both at once.

## Things worth noticing

- Bucket names are **globally unique across all of GCP**, not just
  your project. That's why the name includes the project ID — plain
  names like `my-bucket` are almost always already taken.
- `terraform destroy` will fail if the bucket has objects in it,
  unless `force_destroy = true` is set (used in later exercises that
  add objects to a bucket, like
  [006_upload_bucket_object](../../006_upload_bucket_object)).
