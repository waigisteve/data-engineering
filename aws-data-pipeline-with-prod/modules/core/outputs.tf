
output "s3_bucket_name" {
  value = aws_s3_bucket.data_lake.bucket
}

output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}
