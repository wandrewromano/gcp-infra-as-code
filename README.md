# Terraform + GCP: Intro Course

Start with [000_start_here](000_start_here) — it walks through
finding your GCP project ID, authenticating, and the `init`/`plan`/
`apply`/`destroy` workflow you'll repeat in every exercise below.
Then work through the twenty-five numbered exercises in order of
increasing difficulty. Each folder is self-contained: work inside it,
don't reference other exercises' state. [026_packer_image](026_packer_image)
is optional, past the required sequence — see its own README.

Each numbered exercise folder has two subfolders:

- **`task/`** — the README and starter code (with `TODO`s) you work
  from.
- **`solution/`** — a complete, working implementation. Try the
  exercise yourself first — the solution is there to check your work
  or unstick you, not to copy before attempting it.

| # | Exercise | Concepts |
|---|---|---|
| [000_start_here](000_start_here) | Get your project ID, authenticate, learn the Terraform workflow | `gcloud auth`, `init`/`plan`/`apply`/`destroy` |
| [001_connect_to_gcp](001_connect_to_gcp/task) | Connect Terraform to GCP | provider, auth, `init`/`plan` |
| [002_create_storage_bucket](002_create_storage_bucket/task) | Your first resource: a storage bucket | resources, `apply`/`destroy` |
| [003_variables_and_outputs](003_variables_and_outputs/task) | Variables and outputs | `variable`, `output`, `terraform.tfvars` |
| [004_locals](004_locals/task) | Locals | `locals`, derived values, `merge()` |
| [005_variable_validation](005_variable_validation/task) | Variable validation | `validation` blocks, fail-fast errors |
| [006_upload_bucket_object](006_upload_bucket_object/task) | Uploading a file to your bucket | resource dependencies |
| [007_count_for_each](007_count_for_each/task) | count / for_each | multiple resources from one block |
| [008_create_vpc_network](008_create_vpc_network/task) | A custom VPC network | `google_compute_network`/`subnetwork` |
| [009_builtin_functions](009_builtin_functions/task) | Built-in functions | `cidrsubnet()`, `format()`, `jsonencode()` |
| [010_firewall_rules](010_firewall_rules/task) | Firewall rules | `google_compute_firewall`, least privilege |
| [011_conditionals](011_conditionals/task) | Conditional expressions | ternary expressions |
| [012_dynamic_blocks](012_dynamic_blocks/task) | Dynamic blocks | `dynamic`, generating nested blocks from a list |
| [013_create_vm](013_create_vm/task) | Deploy a VM | `google_compute_instance`, startup scripts |
| [014_templatefile_startup_script](014_templatefile_startup_script) | templatefile() (Part 1: render to output, Part 2: VM startup script) | rendering config files, `templatefile()` |
| [015_service_accounts_iam](015_service_accounts_iam/task) | Service accounts and IAM | least-privilege IAM |
| [016_secret_manager](016_secret_manager/task) | Secret Manager | `google_secret_manager_secret`, keeping values out of Terraform state |
| [017_provider_aliases](017_provider_aliases/task) | Provider aliases | `alias`, multi-region/multi-project |
| [018_build_a_module](018_build_a_module/task) | Build a module | modules, `source`, reusability |
| [019_remote_state](019_remote_state/task) | Remote state | `backend "gcs"`, state locking |
| [020_state_bucket_least_privilege](020_state_bucket_least_privilege/task) | Least-privilege access to the state bucket | scoped IAM, `google_storage_bucket_iam_member` |
| [021_configuration_drift](021_configuration_drift/task) | Configuration drift | `plan`, `apply -refresh-only`, state vs. reality |
| [022_audit_log_alerts](022_audit_log_alerts/task) | Alerting on manual (non-Terraform) changes | Cloud Audit Logs, log-based metrics, alert policies |
| [023_state_mv_rm](023_state_mv_rm/task) | terraform state mv / rm | refactoring addresses without destroying resources |
| [024_import_existing_resources](024_import_existing_resources/task) | Migrating existing resources | `import` blocks, `-generate-config-out` |
| [025_capstone_module](025_capstone_module/task) | Capstone: build a module | modules, capstone project |
| [026_packer_image](026_packer_image) (optional) | Packer (Part 1: build an image, Part 2: use it from Terraform) | machine images, "baking" vs. startup scripts |

## General setup

See [000_start_here](000_start_here) for finding your project
ID, authenticating, and the full `init`/`plan`/`apply`/`destroy`
workflow. Always run `terraform destroy` before moving to the next
exercise so you aren't paying for resources you're done with.
