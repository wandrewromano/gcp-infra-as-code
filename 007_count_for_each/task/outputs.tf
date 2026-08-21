output "bucket_urls" {
  value = { for env, b in google_storage_bucket.my_bucket : env => b.url }

}