# 026 — Packer: Build an Image, Then Use It (Optional)

**Goal:** learn Packer — a separate HashiCorp tool from Terraform —
by building a custom machine image with software pre-installed, then
deploying a VM from it with Terraform.

This exercise is **optional**, unlike everything from
[000_start_here](../000_start_here) through
[025_capstone_module](../025_capstone_module). It introduces a whole
new tool, not just a new Terraform concept, so it's here as a "where
to go next" rather than required curriculum. It's split into two
parts — do them in order.

- **[Part 1 — Build an Image with Packer](part1_build_image/task)** —
  no Terraform at all. Write a Packer template, install one package
  into a fresh image, and confirm the image exists.
- **[Part 2 — Deploy a VM from Your Packer Image](part2_use_image/task)**
  — back to familiar territory: a Terraform config almost identical to
  [013_create_vm](../013_create_vm)'s, except the boot disk comes from
  your Packer image instead of a stock one, and there's no startup
  script left to write.

[Visit the Official Packer Documentation Here](https://developer.hashicorp.com/packer)
