# 015 — Service Accounts and IAM

**Goal:** practice least-privilege IAM instead of relying on the
default compute service account.

[Visit the Official google_service_account Resource Documentation Here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account)

[Visit the Official google_storage_bucket_iam_member Resource Documentation Here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam)

## What are IAM, service accounts, and roles?

**IAM (Identity and Access Management)** is GCP's system for
controlling who — or *what* — can do what. Every API call GCP
receives, including every `terraform apply`, is made *as* some
identity, and IAM decides whether that identity is allowed to do the
thing it's asking for.

A **service account** is an identity meant for a machine instead of a
person — your VM needs to prove who it is when it reads from a
bucket, just like you needed `gcloud auth` in
[000_start_here](../../000_start_here), but "a person typing a
password" doesn't make sense for a VM. Every VM already runs as
*some* service account by default (a broad, shared one Compute Engine
creates automatically); this exercise gives it its own, narrower one
instead.

A **role** is a named bundle of permissions you grant to an identity
on a specific resource — `roles/storage.objectViewer` bundles up
"can read objects in this bucket," `roles/storage.admin` bundles up
far more (create/delete buckets, change permissions, etc.). Granting
the broad role because it's easier is exactly the anti-pattern this
exercise's Goal — least-privilege — pushes back on: give an identity
only the specific roles it actually needs, on only the specific
resources it needs them on.

## Setup

`variables.tf` already has `project_id`/`region` pre-filled — that
part goes back to [003_variables_and_outputs](../003_variables_and_outputs).
`terraform.tfvars` is already here too, committed with placeholder
values — just edit `project_id` to your real project ID (see 003's
README for why this file is committed instead of gitignored).

## Tasks

1. Rebuild (or copy in) the network, subnet, firewall rules, and VM
   from [013_create_vm](../013_create_vm).
2. Define a `google_service_account` for your VM, e.g. `vm-runner`
   with a descriptive `display_name`.
3. Grant it only the roles it actually needs — for example
   `roles/storage.objectViewer` on a specific bucket via
   `google_storage_bucket_iam_member`, **not**
   `roles/storage.admin` on the whole project.
4. Update the `google_compute_instance` you rebuilt in step 1 to use
   this service account instead of the default one:
   ```hcl
   service_account {
     email  = google_service_account.vm_runner.email
     scopes = ["cloud-platform"]
   }
   ```
5. Run `terraform apply` and confirm from inside the VM that it can
   read from the bucket but not, say, list other projects' resources.

## Success criteria

The VM authenticates as your custom service account (check
`gcloud compute instances describe` for `serviceAccounts[].email`),
and that service account's permissions are scoped to exactly one
bucket, not the whole project.

## Discussion question

Why is `google_storage_bucket_iam_member` (resource-level) preferable
to `google_project_iam_member` (project-level) here? What's the
blast radius difference if the VM's credentials were ever leaked?
