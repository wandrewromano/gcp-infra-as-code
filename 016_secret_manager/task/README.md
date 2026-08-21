# 016 — Secret Manager

**Goal:** create a Secret Manager secret with Terraform, and add its
value the right way — outside Terraform entirely, so the value never
touches Terraform's state.

[Visit the Official google_secret_manager_secret Resource Documentation Here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret)

[Visit the Official Secret Manager: Add a Secret Version Documentation Here](https://cloud.google.com/secret-manager/docs/add-secret-version)

## Why the value never goes through Terraform at all

The obvious approach is a `sensitive = true` variable, passed to a
`google_secret_manager_secret_version` resource. Don't do that here —
`sensitive = true` only masks a value from `plan`/`apply` **output**;
it does nothing to the **state file**. Once a value flows into any
resource argument, Terraform writes it to `terraform.tfstate` in
plaintext, permanently, regardless of how carefully you typed it in.
Whether you passed it via `-var`, an environment variable, or hand-typed
it into a prompt doesn't matter — the moment it's a Terraform-managed
value, it's sitting in your state file.

The actual fix isn't a safer way to type the value — it's to never let
it become a Terraform-managed value in the first place. This exercise
has Terraform create the secret **container** (`google_secret_manager_secret`)
and stop there. The value itself gets added afterward, directly
against the Secret Manager API — outside Terraform's plan/apply/state
pipeline entirely, the same way a real pipeline injects secrets from a
vault at deploy time rather than writing them into the infrastructure
code that provisions the vault.

## A note on viewing the value yourself

By default, only Owner-level accounts can view a secret's value —
Secret Manager isn't covered by the broad Editor/Viewer roles the way
most GCP services are (this is a deliberate Google design choice, not
an oversight: Secret Manager and Cloud KMS are two of a small number
of services carved out of Editor specifically because they hold
sensitive material). If `gcloud secrets versions access` or the
Console's "View secret value" fails for you in step 6 below, that's
this, not a mistake in your code — a real team would grant explicit,
narrow `roles/secretmanager.secretAccessor` access to whichever
service account or person actually needs to read it (see "Things
worth noticing" in the solution README for what that looks like in
code).

Creating the secret doesn't grant you access to it — those are two
separate permissions. To view it yourself, someone with
`roles/secretmanager.admin` (or Owner) on the project would need to
grant your account `secretmanager.secretAccessor` on this one secret,
or grant you the admin role directly. Granting that access requires
`secretmanager.secrets.setIamPolicy`, which is exactly the permission
this exercise's own IAM-granting step (see "Things worth noticing" in
the solution README) needs and many training projects don't include —
not something fixable from inside Terraform, since you can't grant
yourself a permission you don't already have.

## Setup

`variables.tf` already has `project_id`/`region` pre-filled — that
part goes back to [003_variables_and_outputs](../003_variables_and_outputs).
`terraform.tfvars` is already here too, committed with placeholder
values — just edit `project_id` to your real project ID.

## Tasks

1. Enable the Secret Manager API:
   ```bash
   gcloud services enable secretmanager.googleapis.com --project YOUR_PROJECT_ID
   ```
   or manage it with a `google_project_service` resource, as in
   earlier exercises.
2. Define a `google_secret_manager_secret` (secret ID `app-secret`)
   with automatic replication — Secret Manager stores encrypted
   copies of the secret's value across multiple regions so it's still
   available if one region has an outage; `auto {}` tells GCP to pick
   suitable regions for you instead of you naming them:
   ```hcl
   replication {
     auto {}
   }
   ```
   Do **not** define a `google_secret_manager_secret_version` resource
   — that's the whole point of this exercise.
3. Run `terraform apply`. Confirm the secret exists but has no version
   yet:
   ```bash
   gcloud secrets versions list app-secret
   # (empty — Listed 0 items.)
   ```
4. Add the actual value **outside Terraform** — see the section below
   for both ways to do it.
5. Run `terraform plan` — confirm it shows **no changes**. Terraform
   has no resource tracking the secret's version, so it has nothing to
   notice or reconcile.
6. Confirm the value never touched Terraform's own bookkeeping:
   ```bash
   grep -r "correct-horse-battery-staple" terraform.tfstate
   ```
   This should return nothing. Compare that to what would happen if
   you'd used a `google_secret_manager_secret_version` resource with
   `secret_data = var.secret_value` instead — grep the state file for
   that value, and it would be right there in plaintext.
7. Try to confirm the value is retrievable through Secret Manager
   itself:
   ```bash
   gcloud secrets versions access latest --secret=app-secret
   ```
   or via the Console (see the section below). See the permissions
   note above if this fails for your account — that's expected in some
   training environments, not a sign anything is broken.

## Adding a Secret Value (Once the Secret Container Exists)

After step 3, `app-secret` exists but has zero versions — there's
nothing to read yet. Both methods below add a **new version** holding
your value; they're equivalent, pick whichever you want to practice.
The examples use `correct-horse-battery-staple` as a stand-in
value — swap in anything you want, it doesn't matter what it is for
this exercise, only that it never touches a Terraform resource. Every
time you add a value this way (even the same value twice), it becomes
a new version number (`1`, `2`, `3`, ...) rather than overwriting the
last one — Secret Manager keeps every version around until you
explicitly disable or destroy it.

**gcloud:**
```bash
echo -n "correct-horse-battery-staple" | gcloud secrets versions add app-secret --data-file=-
```
`--data-file=-` reads the value from stdin instead of a command-line
argument or a file on disk — nothing here ends up in your shell
history or a temp file the way `--data-file=/tmp/secret.txt` or a
literal value typed as an argument would. Output confirms which
version number you just created, e.g. `Created version [1] of the
secret [app-secret].`

**GCP Console:**
1. Console → search bar → "Secret Manager" (or Navigation menu →
   Security → Secret Manager).
2. Click into `app-secret`.
3. Click **+ NEW VERSION** (top of the page, or on the **Versions**
   tab).
4. Paste or type the value into the field. There's no confirmation
   step showing you the value back — double-check what you pasted
   before continuing, since the field itself is masked.
5. Click **ADD NEW VERSION**. The new version appears in the list
   immediately, with a status of **Enabled**.

Either way, confirm it worked from the command line:
```bash
gcloud secrets versions list app-secret
```
You should now see at least one version listed, where step 3 showed
none.

## Viewing Secret Manager in the GCP Console

Worth a look even if you did everything else through `gcloud` — this
is where you'd go to check on a secret someone else created, or to
confirm what a Terraform config actually did.

1. **Navigate there:** Console → search bar (top of the page) → type
   "Secret Manager" → click the result. Or: Navigation menu (☰) →
   Security → Secret Manager.
2. **The list page** shows every secret in the project — name,
   replication setting, creation time. Find `app-secret` and click
   into it.
3. Inside a secret, there are a few tabs worth knowing:
   - **Overview** — the secret's ID, replication policy, and labels.
     This is the container Terraform created (`terraform state list`
     shows this same resource).
   - **Versions** — every version ever added, each with a version
     number, state (Enabled/Disabled/Destroyed), and creation time.
     The value you added in step 4 shows up here as version `1` —
     Secret Manager tracks this regardless of whether Terraform does,
     because versions are the API's concept, not Terraform's.
   - **Permissions** — the IAM bindings on this one secret. This tab
     is normally where you'd see who's been granted
     `Secret Manager Secret Accessor` — see the permissions note above
     for why this exercise doesn't create one for you.
4. **To reveal a version's value:** on the **Versions** tab, find the
   version's row, click the **⋮** (three-dot menu) at the end of it →
   **View secret value**. Requires `secretmanager.versions.access` on
   your account — see the permissions note above if this fails.

Notice what's split across these tabs: **Overview** is exactly what
your `.tf` files describe and `terraform state list` knows about.
**Versions** — where the actual value lives — isn't.

## Success criteria

- `terraform state list` shows the secret container — Terraform
  manages its existence.
- No `google_secret_manager_secret_version` resource exists anywhere
  in your `.tf` files.
- A version exists (`gcloud secrets versions list app-secret` shows at
  least one), added by you, outside Terraform.
- Grepping `terraform.tfstate` for the value you chose finds nothing.

## Discussion question

If you'd used a `sensitive = true` variable and a
`google_secret_manager_secret_version` resource instead, `terraform
plan`/`apply` output would never have shown the value — but it would
still be sitting in `terraform.tfstate` in plaintext. Now that the
value never touches Terraform at all, what's actually protecting it?
(See [019_remote_state](../019_remote_state) and
[020_state_bucket_least_privilege](../020_state_bucket_least_privilege)
for what — or who — that answer points to.)
