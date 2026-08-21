terraform {
  required_version = ">= 1.7.0"
}

output "rendered_message_01" {
  value = templatefile("${path.module}/templates/welcome.tftpl", {
    name = var.your_name
  })
}

output "rendered_message_02" {
  value = templatefile("${path.module}/templates/welcome.tftpl", {
    name = "John"
  })
}
