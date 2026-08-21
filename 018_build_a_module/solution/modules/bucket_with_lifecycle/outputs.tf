output "bucket_url" {
  value = google_storage_bucket.this.url
}

output "bucket_name" {
  value = google_storage_bucket.this.name
}
