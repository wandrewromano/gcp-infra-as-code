output "bucket_url" {
  description = "bucket URL"
  value = google_storage_bucket.my_bucket.url
}

output "bucket_self_link" {
  description = "bucket self link"
  value = google_storage_bucket.my_bucket.self_link
}