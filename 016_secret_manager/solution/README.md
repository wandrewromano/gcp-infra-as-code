# 016 — Solution: Secret Manager

## What this creates

- **`google_secret_manager_secret.app_secret`** — the secret
  container only. No `google_secret_manager_secret_version` resource
  anywhere in this config, on purpose.

That's it — this exercise deliberately stops there. See "Things worth
noticing" below for why it doesn't also grant a service account access
to the secret.

## Why no `google_secret_manager_secret_version` resource

`sensitive = true` on a variable only masks it from `plan`/`apply`
**output** — it does nothing to the **state file**. The moment a
value flows into any resource argument (`secret_data = var.secret_value`,
for instance), Terraform writes that value to `terraform.tfstate` in
plaintext, and it stays there. Marking the variable `sensitive`
doesn't change that; it just stops the value from showing up on your
screen while it happens.

The fix isn't a safer way to pass the value into Terraform — it's to
never let Terraform touch the value at all. This config manages the
secret's existence and stops there; the value itself is added
directly against the Secret Manager API afterward (README.md step 4),
completely outside `plan`/`apply`/state. This is also the realistic
pattern: a real pipeline's Terraform run provisions a vault or a
Secret Manager entry, and a *separate* process — a human, a vault's
own injection step, a break-glass script — populates the value. The
system that provisions secret storage and the system that knows
secret values are rarely the same actor.

## Why not just a variable with a default, or a value baked into a startup script

Both are common shortcuts, and both leave the secret sitting in
plaintext somewhere durable — a `default` value lives in your `.tf`
files (and your git history, forever, even after you remove it); a
value baked into a startup script sits in plaintext in the instance's
metadata, readable by anything with `compute.instances.get` on that
VM. Secret Manager exists specifically to break that pattern: the
value is stored once, access is controlled by IAM like any other
resource, and every access is logged — none of which is true of a
value sitting in a `.tf` file or instance metadata.

## Things worth noticing

- `terraform plan` after adding the value out-of-band (README.md step
  5) shows no changes — there's no resource in this config that
  models the version at all, so Terraform has nothing to compare
  against. That's different from drift ([021_configuration_drift](../../021_configuration_drift)):
  drift is Terraform noticing a *managed* resource changed outside its
  control; this is Terraform correctly having no opinion about
  something it was never told to manage.
- `grep`-ing `terraform.tfstate` for the value (step 6) is the actual
  proof this approach works — not a claim to take on faith. If you
  want to see the failure mode this avoids, temporarily add a
  `sensitive = true` variable and a `google_secret_manager_secret_version`
  resource using it, `apply`, then grep state for the value you passed
  in. It's there, in plaintext, despite `sensitive = true`.
- **This config doesn't grant anyone access to the secret.** In an
  environment where your account has `roles/secretmanager.admin` (not
  the case in every training project — see the task README's
  permissions note), you'd normally add exactly what
  [015_service_accounts_iam](../../015_service_accounts_iam) and
  [020_state_bucket_least_privilege](../../020_state_bucket_least_privilege)
  already showed for other resource types — a dedicated service
  account, scoped to this one secret, nothing broader:
  ```hcl
  resource "google_service_account" "secret_reader" {
    account_id   = "secret-reader"
    display_name = "Secret reader"
  }

  resource "google_secret_manager_secret_iam_member" "secret_reader_accessor" {
    secret_id = google_secret_manager_secret.app_secret.id
    role      = "roles/secretmanager.secretAccessor"
    member    = "serviceAccount:${google_service_account.secret_reader.email}"
  }
  ```
  This isn't applied here because granting IAM on a Secret Manager
  resource requires `secretmanager.secrets.setIamPolicy`, which many
  training/sandbox projects don't include — but the pattern itself
  (scope a service account to exactly the one resource and exactly
  the one capability it needs) is unchanged from every other exercise
  that's used it.
- `google_secret_manager_secret` and a secret *version* are separate
  concepts in Secret Manager regardless of how the version gets
  created — a secret can hold many versions over its lifetime (e.g.
  after rotation), and most real consumers fetch "latest" rather than
  pin to one. That's true whether Terraform manages versions or not;
  this exercise just chooses not to have Terraform be the thing that
  creates them.
