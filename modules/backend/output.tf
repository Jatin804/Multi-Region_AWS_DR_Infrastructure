output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value = aws_s3_bucket.app_data.id
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value = aws_dynamodb_table.app_sessions.name
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value = aws_db_instance.app_database.endpoint
}

output "frontend_instance_profile_name" {
  description = "The IAM instance profile to attach to the Frontend EC2 instances"
  value = aws_iam_instance_profile.frontend_profile.name
}