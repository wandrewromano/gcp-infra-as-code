# 000 — Start Here

Do this once before starting the following exercises.

[Visit the Official Terraform + GCP Get Started Tutorial Here](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started)

You don't need to know any Terraform syntax to start, even if you've
never written a line of HCL (Terraform's config language) before.
[001_connect_to_gcp](../001_connect_to_gcp) teaches the shape of a
Terraform block using the actual file you'll be editing, right when
you need it — nothing here in 000 assumes you already know it.

## 1. Find your GCP project ID

Terraform needs to know exactly which GCP project to create resources
in — there's no default, and project IDs are globally unique, so
nobody can hand you one that "just works." Pick whichever of these
matches your setup:

- **If `gcloud` is already configured in your environment** (common
  in auto-provisioned sandbox/lab environments):
  ```bash
  gcloud config get-value project
  ```
- **To see every project you have access to:**
  ```bash
  gcloud projects list
  ```
  This prints `PROJECT_ID`, `NAME`, and `PROJECT_NUMBER`. You want the
  **ID** — it's not always the same as the display name, and it's
  different from the numeric project number.
- **In the GCP Console:** console.cloud.google.com → the project
  picker at the top of the page, or the "Project info" card on the
  Home/Dashboard page.
- **In a temporary/sandbox lab environment** (e.g. Qwiklabs / Google
  Cloud Skills Boost style): the assigned project ID is usually
  printed directly on the lab instructions panel when your
  environment is provisioned — often something like
  `qwiklabs-gcp-01-xxxxxxxx`.

Write it down — you'll need it in every exercise folder. If none of
the above turned up a project (e.g. `gcloud projects list` comes back
empty), go to step 1 to create one, then come back here.

Make sure to set your project in GCP as to not accidentally update the wrong project.
`gcloud config set project training-project-XX` 


## 2. Authenticate

Two separate logins are required, because they serve different tools:

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

- `gcloud auth login` authenticates the `gcloud` CLI itself, so you
  can run `gcloud` commands (useful for verifying what Terraform
  created).
- `gcloud auth application-default login` writes **Application
  Default Credentials (ADC)** to a well-known local file. This is
  what Terraform's `google` provider actually reads — it doesn't use
  your `gcloud auth login` session. Skip this one and `terraform
  plan` will fail with a "could not find default credentials" error.
- `gcloud config set project` sets the default project for `gcloud`
  commands. It does **not** affect Terraform — Terraform only knows
  the project ID you put in the `.tf` files themselves (next step).

## 3. Put your project ID into an exercise

Exactly how you do this changes a couple of times as you move through
the course. You don't need to memorize any of it now — each exercise
below tells you what to do and explains why, right when you get
there:

- **001 and 002** — a blank field to fill in directly in `main.tf`.
- **003 and 004** — a `terraform.tfvars` file you create by hand and
  commit, same as any other file in this course.
- **005 onward** — `terraform.tfvars` is already there for you,
  committed with a placeholder value — just edit it.

Just follow whatever that exercise's own README says. One value in
the whole course is the exception to "commit it like everything
else": [016_secret_manager](../016_secret_manager) introduces an
actually-sensitive value, and that exercise explains why it's handled
completely differently.

## 4. The Terraform workflow (repeat this in every exercise)

Run these from inside an exercise's `task/` (or `solution/`) folder:

```bash
terraform fmt        # auto-formats your .tf files to canonical style
terraform init        # downloads the google provider, sets up the working directory
terraform plan         # shows what would change — nothing is created yet
terraform apply        # actually creates the resources (this is what costs money/affects your project)
# ...verify your work, e.g. with gcloud or the GCP Console...
terraform destroy      # tears everything back down
```

- `fmt` is safe and non-destructive — it only rewrites whitespace and
  alignment in your `.tf` files to Terraform's canonical style. Get in
  the habit of running it before `plan`; it costs nothing and keeps
  every exercise's code consistent, which matters once more than one
  person is reading it.
- `init` is safe to re-run any time; it doesn't touch GCP resources.
- `plan` is read-only — always run it before `apply` so you know what
  you're about to create.
- `apply` will prompt you to type `yes` before it does anything.
- **Always run `terraform destroy` before moving to the next
  exercise.** Nothing here is designed to run continuously, and
  leaving resources up across exercises is how you end up paying for
  things you're done with.
- Every `init`/`plan`/`apply` also reads and writes a local
  `terraform.tfstate` file in that folder — Terraform's own record of
  what it believes it created and with what configuration. `plan`
  works by comparing your `.tf` files against this file, not against
  GCP directly asking "does this exist yet?" every time. You won't
  need to think about this file much until
  [019_remote_state](../019_remote_state), which moves it off local
  disk, and [021](../021_configuration_drift)–[024](../024_import_existing_resources),
  which are entirely about what happens when this file and the real
  world disagree — but it's been there, quietly, since your very
  first `terraform apply` in
  [002_create_storage_bucket](../002_create_storage_bucket).

## 5. Finding what you created in GCP

`terraform apply` tells you what it created, but it's worth actually
looking at resources in the Console or `gcloud` too — that's the
skill you'll use once you're not running Terraform yourself (e.g.
debugging something a teammate or a CI pipeline created).

- The Console always scopes what you see to **the currently selected
  project** (top-left project picker). If you don't see something you
  just created, check that first — it's the most common cause of
  "it's not there."
- The **search bar** at the top of the Console ("Search products and
  resources, docs, and more") can jump straight to a resource by
  name — faster than clicking through the left-hand navigation menu.
- The left-hand navigation menu (☰) groups services by category —
  Cloud Storage and Compute Engine are both under "Storage" /
  "Compute" respectively, and Networking/IAM have their own sections.
- Most resource types also have a `gcloud ... list` equivalent (e.g.
  `gcloud compute instances list`, `gcloud storage buckets list`) if
  you'd rather check from the terminal than the Console.

A couple of exercises give you a direct link for free — `013_create_vm`'s
solution outputs `vm_external_ip`, and `terraform output` after any
`apply` will print whatever that exercise defined, which is often
faster than navigating the Console at all.

## 6. Manual ("clickops") resources — [021_configuration_drift](../021_configuration_drift) and [024_import_existing_resources](../024_import_existing_resources)

Two exercises deliberately have you touch GCP outside of Terraform —
`021_configuration_drift` has you edit a resource by hand with
`gcloud`, and `024_import_existing_resources` has you create a bucket
by hand before Terraform ever knows about it. Both are intentional:
you can't learn how Terraform handles "someone changed this by hand"
without actually doing it. But it means Terraform doesn't know about
these resources yet, so `terraform destroy` won't reliably clean them
up.

- **Label every manually-created or manually-modified resource with
  `clickops_resource=true`** as you create/edit it, e.g.:
  ```bash
  gcloud storage buckets update gs://YOUR_BUCKET --update-labels=clickops_resource=true
  # or at creation time:
  gcloud storage buckets create gs://YOUR_BUCKET --labels=clickops_resource=true
  ```
  This makes anything you touched outside Terraform easy to spot in
  the Console (filter by label) instead of blending in with
  Terraform-managed resources.
- **Clean up depends on whether you finished the exercise:**
  - If a manually-created resource ends up successfully imported into
    Terraform (as in `024`), it's now Terraform-managed — a normal
    `terraform destroy` handles it like anything else.
  - If you stop partway — created something by hand but never
    imported it, or abandoned the exercise — Terraform still doesn't
    know it exists, and you must delete it yourself:
    ```bash
    gcloud storage buckets delete gs://YOUR_BUCKET
    ```
  - Either way, before moving on, sweep for anything you might have
    left behind:
    ```bash
    gcloud storage buckets list --filter="labels.clickops_resource=true"
    ```
    Delete anything that shows up here that isn't already covered by
    a `terraform destroy`.

## 7. `task/` vs `solution/`

Every exercise folder has both. Work in `task/` first — it has the
README with instructions and a `main.tf` with `TODO`s for you to
fill in. `solution/` is a complete, working version to check your
work against or unstick you if you're stuck, not something to copy
before you've tried.
