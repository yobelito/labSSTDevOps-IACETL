output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.glue_scripts_bucket.bucket
}
output "aws_s3_bucket" {
  description = "url del bucket S3"
    value       = aws_s3_bucket.glue_scripts_bucket.id
}