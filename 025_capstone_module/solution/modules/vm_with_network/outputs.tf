output "vm_external_ip" {
  value = google_compute_instance.this.network_interface[0].access_config[0].nat_ip
}

output "network_self_link" {
  value = google_compute_network.this.self_link
}
