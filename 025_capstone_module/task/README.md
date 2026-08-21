# 025 — Capstone: Build a Module

**Goal:** refactor everything from exercises 008, 010, 013 (network,
firewall, VM) into a reusable module, then call it twice with
different inputs.

[Visit the Official Terraform Modules Overview Documentation Here](https://developer.hashicorp.com/terraform/language/modules)

## Setup

The root `variables.tf` already has `project_id`/`region` pre-filled
— that part goes back to
[003_variables_and_outputs](../003_variables_and_outputs) — and the
root `terraform.tfvars` is already here too, committed with
placeholder values — just edit `project_id` to your real project ID.
This is the same root-vs-module split from
[018_build_a_module](../018_build_a_module): the root config reads
`terraform.tfvars`, and passes what the module needs through the
`module` block's own inputs — the module never reads the root's
tfvars directly.

## Tasks

1. Inside this folder, create a `modules/vm_with_network/` directory
   containing:
   - `main.tf` — the network, subnet, firewall rules, and VM
     resources, generalized (no hardcoded names)
   - `variables.tf` — inputs like `name_prefix`, `region`, `zone`,
     `machine_type`, `subnet_cidr`
   - `outputs.tf` — at least the VM's external IP and the network's
     self link
2. In this folder's root `main.tf`, call the module **twice** with
   different `name_prefix` and `subnet_cidr` values — e.g. a "dev"
   instance and a "staging" instance, each in its own network so
   there's no CIDR collision.
3. Run `terraform apply` and confirm two independent VM + network
   pairs are created.
4. Run `terraform destroy` when finished.

## Success criteria

- The module has no hardcoded resource names — everything that
  varies between the two calls comes from module inputs.
- Both module instances coexist without CIDR or naming conflicts.
- `terraform output` shows both VMs' external IPs distinctly (hint:
  you'll need to reference `module.dev.vm_external_ip` and
  `module.staging.vm_external_ip` from the root outputs).

## Discussion question

What did moving this into a module force you to make explicit that
wasn't explicit in exercise 013? What would you still need to add
before this module was safe to reuse across a whole team (e.g.
remote state per instance, variable validation, naming conventions)?
