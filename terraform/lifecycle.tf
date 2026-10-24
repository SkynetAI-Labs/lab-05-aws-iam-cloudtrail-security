variable "cloudtrail_current_retention_days" {
  description = "Learning-lab days before current CloudTrail objects expire."
  type        = number
  default     = 90

  validation {
    condition = (
      var.cloudtrail_current_retention_days >= 1 &&
      floor(var.cloudtrail_current_retention_days) == var.cloudtrail_current_retention_days
    )
    error_message = "Retention must be a positive whole number of days."
  }
}

variable "cloudtrail_noncurrent_retention_days" {
  description = "Days before permanently deleting versions after they become noncurrent."
  type        = number
  default     = 90

  validation {
    condition = (
      var.cloudtrail_noncurrent_retention_days >= 1 &&
      floor(var.cloudtrail_noncurrent_retention_days) == var.cloudtrail_noncurrent_retention_days
    )
    error_message = "Retention must be a positive whole number of days."
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    id     = "cloudtrail-log-retention"
    status = "Enabled"

    filter {}

    expiration {
      days = var.cloudtrail_current_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.cloudtrail_noncurrent_retention_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.cloudtrail_logs
  ]
}
