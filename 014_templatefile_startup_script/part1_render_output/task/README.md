# 014 (Part 1) — Render a Template to Output

**Goal:** see `templatefile()` do its one job — fill in a template's
blanks from a map of values — with nothing else going on: no VM, no
waiting, no network, no GCP resource at all.

[Visit the Official Terraform templatefile() Function Documentation Here](https://developer.hashicorp.com/terraform/language/functions/templatefile)

## What is templatefile(), and why do we even want it?

`templatefile(path, vars)` takes a text file with blanks in it and
fills those blanks in with real values you give it — like a form
letter, or Mad Libs. You write the file once with a placeholder like
`${name}`, and Terraform swaps in whatever value you pass for `name`
when it runs.

Why bother, instead of just writing the text you want directly? Two
ordinary reasons:

- **You want the same file to produce different results.** Hardcode
  `"Hello, Student!"` directly in your Terraform code and that's the
  only thing it'll ever say. A template (`Hello, ${name}!`) can
  produce `"Hello, Alice!"` or `"Hello, Bob!"` from the exact same
  file, depending on what you pass in.
- **Long text buried inside Terraform code gets ugly fast.** Once
  what you're generating is more than a line or two — a VM startup
  script, a config file — cramming it into a resource block as one
  giant string makes it hard to read and edit. A separate file means
  you can read it, edit it, and get real syntax highlighting for it,
  apart from the Terraform logic that fills it in.

That's the whole function. [Part 2](../../part2_vm_startup_script)
puts it to use inside a VM's startup script — exactly the "long text,
needs to vary" case above — but a VM adds boot time, an external IP,
and `curl` on top of the one new idea, none of which is
`templatefile()` itself. This part strips all of that away so you can
watch the function work in isolation first.

## Setup

`variables.tf` already has `your_name` pre-filled with a default —
edit `terraform.tfvars` if you want to render your own name instead.
Notice there's no `project_id` or `region` here: this part creates no
GCP resource, so it needs no GCP provider at all.

## Tasks

1. Create `templates/welcome.tftpl`:
   ```
   Hello, ${name}! Welcome to Terraform templates.
   ```
2. Add an output that renders it:
   ```hcl
   output "rendered_message" {
     value = templatefile("${path.module}/templates/welcome.tftpl", {
       name = var.your_name
     })
   }
   ```
3. Run `terraform apply` and confirm the rendered message prints in
   the output.
4. Change `your_name` in `terraform.tfvars` and run `terraform apply`
   again — confirm the output updates immediately.

## Success criteria

The `rendered_message` output shows your custom name, and re-running
`apply` after changing the variable updates it right away — no
waiting, nothing else to check.

## Discussion question

You just watched `rendered_message` change the instant you edited
`your_name` and reran `apply`. Hold onto that observation for
[Part 2](../../part2_vm_startup_script) — you'll change a similarly-named
variable there, and the result will **not** update that instantly, even
though `templatefile()` is doing the exact same kind of rendering in
both cases. What's different about where each rendered value ends up?
