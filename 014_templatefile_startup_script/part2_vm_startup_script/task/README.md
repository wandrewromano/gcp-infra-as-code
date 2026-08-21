# 014 (Part 2) — templatefile() for a Startup Script

**Goal:** apply `templatefile()` to something real — a VM's startup
script — now that [Part 1](../../part1_render_output) showed you the
function in isolation.

[Visit the Official Terraform templatefile() Function Documentation Here](https://developer.hashicorp.com/terraform/language/functions/templatefile)

## Why templatefile() instead of a heredoc

[013_create_vm](../../../013_create_vm)'s startup script is a heredoc
(`<<-EOT ... EOT`) written directly inside the resource block — fine
for a short, static script, but that stops working well the moment
the script needs to vary: a value pulled from a variable, different
packages per environment, or just a script long enough that burying
it inside `main.tf` hurts readability. `templatefile(path, vars)`
reads a file from disk and renders it with the variables you pass in
— the same function you used in Part 1, just wired into
`metadata_startup_script` instead of an `output`.

## Setup

`variables.tf` already has `project_id`/`region` pre-filled — that
part goes back to [003_variables_and_outputs](../../../003_variables_and_outputs).
`terraform.tfvars` is already here too, committed with placeholder
values — just edit `project_id` to your real project ID (see 003's
README for why this file is committed instead of gitignored).

## Tasks

1. Reuse the VM/network/firewall pattern from
   [013_create_vm](../../../013_create_vm).
2. Create `templates/startup.sh.tftpl`:
   ```bash
   #!/bin/bash
   apt-get update
   apt-get install -y apache2
   echo "${welcome_message}" > /var/www/html/index.html
   ```
3. Define a variable `welcome_message` (string, default
   `"Hello from Terraform templatefile()!"`).
4. In the `google_compute_instance` resource, render the template
   instead of writing the script inline:
   ```hcl
   metadata_startup_script = templatefile("${path.module}/templates/startup.sh.tftpl", {
     welcome_message = var.welcome_message
   })
   ```
5. Run `terraform apply`, wait a minute for the startup script to run,
   then `curl http://<external-ip>` and confirm your custom message
   appears.
6. Change `welcome_message` and run `terraform plan` — what does
   Terraform propose to change, and why?

## Success criteria

The rendered page shows your custom `welcome_message`, and you can
explain what part of the VM resource changes when you edit the
template versus when you edit the variable's value.

## Discussion question

In [Part 1](../../part1_render_output), changing a variable and
re-`apply`ing updated the output instantly. Here, `templatefile()`
still reads the file and renders it **at plan time**, on your machine
— the VM never sees `startup.sh.tftpl` itself, only the fully-rendered
string in `metadata_startup_script`. Given that, if you change
`welcome_message` and re-`apply` against an **already-running** VM,
does the running VM's web page update automatically? Why does this
case behave differently from Part 1's, even though the same function
renders the same way in both?
