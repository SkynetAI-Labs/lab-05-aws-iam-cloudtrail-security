variable "cloudwatch_log_retention_days" {
  description = "Learning-lab retention period for CloudTrail events in CloudWatch Logs."
  type        = number
  default     = 30

  validation {
    condition = contains(
      [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653],
      var.cloudwatch_log_retention_days
    )
    error_message = "Choose a supported finite CloudWatch Logs retention period."
  }
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/lab05/cloudtrail/security"
  retention_in_days = var.cloudwatch_log_retention_days
  skip_destroy      = false
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_trust" {
  statement {
    sid     = "AllowCloudTrailDelivery"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name               = "lab05-cloudtrail-cloudwatch"
  description        = "Deliver Lab 05 CloudTrail events to its dedicated CloudWatch log group"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_trust.json
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_permissions" {
  statement {
    sid    = "WriteCloudTrailLogStreams"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.cloudtrail.arn}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_*"
    ]
  }
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name   = "lab05-cloudtrail-cloudwatch-delivery"
  role   = aws_iam_role.cloudtrail_cloudwatch.id
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_permissions.json
}
