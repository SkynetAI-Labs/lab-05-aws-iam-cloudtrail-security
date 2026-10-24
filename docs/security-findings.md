# Security findings and limitations

## Historical baseline — 21 October 2026

Checkov 3.3.30: 55 passed, 8 failed, 0 skipped.
The scan assessed the Terraform configuration after the live resources
had been destroyed. Findings remain visible and are not suppressed.

| Check | Gap | Implication and production improvement |
|---|---|---|
| CKV_AWS_252 | No CloudTrail SNS topic | No delivery notifications through SNS. Add a topic and verified subscribers where required. |
| CKV_AWS_35 | No customer-managed KMS key for CloudTrail | Logs use S3 AES256 encryption. Add KMS for separate key policy and key-use auditing. |
| CKV_AWS_18 | No S3 server access logging | Bucket access is not covered by server access logs; S3 data events are also not configured. Add an appropriate access-auditing mechanism. |
| CKV2_AWS_61 | No lifecycle configuration | Retention is manual. Define retention and noncurrent-version expiration for a persistent deployment. |
| CKV_AWS_144 | No cross-region replication | No replicated recovery copy. Add replication where recovery requirements justify it. |
| CKV2_AWS_62 | No S3 event notifications | Log arrival does not trigger downstream processing. Add notifications if needed. |
| CKV2_AWS_10 | No CloudWatch Logs integration | No CloudWatch metric filters or alarms for these logs. Add integration and tested detections for operational monitoring. |
| CKV_AWS_145 | No default S3 KMS encryption | SSE-S3 AES256 was verified live. Add KMS if customer-controlled keys are required. |

## Scope and evidence limits

- This was a temporary learning deployment, not a production monitoring service.
- These gaps are documented limitations, not formally approved enterprise exceptions.
- Management events were configured across regions, excluding KMS and RDS Data API events.
- Data events and CloudTrail Insights were not configured.
- Log delivery and sample event contents were verified.
- Log-file validation was enabled and digest delivery observed; cryptographic integrity validation was not performed.
- Auditor lookup succeeded in eu-north-1 and was denied in eu-west-1.
- IAM ListRoles was denied for the auditor. Destructive write operations were not attempted.
- IAM Access Analyzer returned no findings for the auditor identity policy.
- Terraform reported no drift before cleanup.
- All eight resources were destroyed; AWS APIs confirmed the bucket, role and trail were absent.
- Budget email verification remains pending with AWS Support.

## Updated static scan — 24 October 2026

[GitHub Actions run 40131368211](https://github.com/SkynetAI-Labs/lab-05-aws-iam-cloudtrail-security/actions/runs/40131368211)
checked commit `71316c64d333ed262b64ab25882854c91b539ba2`.
Terraform 1.16.6 formatting, backend-free initialisation and validation passed
with locked AWS provider 6.69.1. Checkov 3.3.30 returned **113 passed,
12 failed, 0 skipped**. The security job and overall workflow failed.
No findings were suppressed. These results assess code, not deployed controls.

### Approved improvements passing static checks

| Check | Resource | Result and evidence limit |
|---|---|---|
| CKV2_AWS_61 | Both S3 buckets | Lifecycle configuration passes; retention behaviour has not been tested live. |
| CKV_AWS_18 | CloudTrail bucket | Access-logging configuration passes; delivery has not been tested live. |
| CKV2_AWS_10 | CloudTrail trail | CloudWatch integration passes; event delivery has not been tested live. |

Checkov also reports CKV_AWS_18 as passed for the access-log destination.
That bucket intentionally has no server access logging configured, avoiding
recursive logging; this scan result is not evidence of destination self-logging.

### Exact remaining failures

| Check | Resource | Gap / scope decision |
|---|---|---|
| CKV_AWS_35 | aws_cloudtrail.security | No customer-managed KMS key; outside approved scope. |
| CKV_AWS_252 | aws_cloudtrail.security | No SNS topic; outside approved scope. |
| CKV_AWS_158 | aws_cloudwatch_log_group.cloudtrail | No customer-managed KMS key; outside approved scope. CloudWatch uses its default at-rest encryption. |
| CKV_AWS_338 | aws_cloudwatch_log_group.cloudtrail | Approved 30-day learning-lab retention is shorter than the check's one-year requirement. |
| CKV_AWS_300 | aws_s3_bucket_lifecycle_configuration.cloudtrail_logs | No automatic abort period for incomplete multipart uploads. |
| CKV_AWS_300 | aws_s3_bucket_lifecycle_configuration.access_logs | No automatic abort period for incomplete multipart uploads. |
| CKV2_AWS_62 | aws_s3_bucket.cloudtrail_logs | No event notifications; outside approved scope. |
| CKV2_AWS_62 | aws_s3_bucket.access_logs | No event notifications; outside approved scope. |
| CKV_AWS_144 | aws_s3_bucket.cloudtrail_logs | No cross-region replication; outside approved scope. |
| CKV_AWS_144 | aws_s3_bucket.access_logs | No cross-region replication; outside approved scope. |
| CKV_AWS_145 | aws_s3_bucket.cloudtrail_logs | Default encryption is SSE-S3 rather than KMS; KMS is outside approved scope. |
| CKV_AWS_145 | aws_s3_bucket.access_logs | SSE-S3 is used for S3 server access-log delivery compatibility. |

The original five out-of-scope check/resource failures remain. Seven additional
failures arise from the new lifecycle resources (two), new access-log bucket
(three) and CloudWatch log group (two). The three targeted baseline failures
now pass. Counts are check/resource pairs, not a percentage measure of security.

### Retention, cleanup and live-verification limits

- Both S3 buckets default to 90 days for current objects plus 90 days after
  becoming noncurrent; overwrites/deletions start the noncurrent clock earlier.
  Deletion is asynchronous, applies to existing eligible objects and is not
  immutable retention. Preserve evidence outside automatic deletion paths.
- Both S3 buckets retain force_destroy = false. Empty versions and delete
  markers deliberately before approved cleanup; account for delayed access logs.
- CloudWatch retention defaults to 30 days. Destroying its log group also
  deletes remaining events; export required evidence before approved cleanup.
- Source-bucket logging depends on the destination policy, ownership,
  encryption and lifecycle. Trail integration depends on its delivery policy.
- Original auditor permissions, S3 protections, trail settings and historical
  deployment/cleanup evidence remain unchanged.
- No new AWS resources have been deployed, no new delivery has been verified,
  and no alarms, metric filters or detections are claimed operational.
- Assess regional ingestion, storage and query costs before separately
  approved deployment. Customer-managed KMS, SNS and replication remain
  outside this implementation scope.
