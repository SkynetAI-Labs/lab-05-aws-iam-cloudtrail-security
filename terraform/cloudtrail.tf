resource "aws_cloudtrail" "security" {
  name                          = local.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
  enable_logging                = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    exclude_management_event_sources = [
      "kms.amazonaws.com",
      "rdsdata.amazonaws.com"
    ]
  }

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_logs,
    aws_s3_bucket_public_access_block.cloudtrail_logs,
    aws_s3_bucket_server_side_encryption_configuration.cloudtrail_logs,
    aws_s3_bucket_versioning.cloudtrail_logs,
    aws_iam_role_policy.cloudtrail_cloudwatch
  ]
}
