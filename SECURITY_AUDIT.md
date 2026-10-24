# Repository Security Audit — Lab 05

**Review date:** 24 October 2026  
**Reviewed source commit:** [`7fe74c80487df876d69ce5b31c44fbd9054b7472`](https://github.com/SkynetAI-Labs/lab-05-aws-iam-cloudtrail-security/tree/7fe74c80487df876d69ce5b31c44fbd9054b7472)  
**Scope:** Public repository configuration, documentation, retained evidence and available workflow results. This is a repository audit, not a fresh live-environment assessment or penetration test.

## Outcome
Terraform formatting, backend-disabled initialization and validation passed in [run 40131772623](https://github.com/SkynetAI-Labs/lab-05-aws-iam-cloudtrail-security/actions/runs/40131772623), for `7fe74c80487df876d69ce5b31c44fbd9054b7472`. Checkov 3.3.30 reported **113 passed, 12 failed, 0 skipped**. The security job failed; the lab is not all-green.

## Evidence checked
- All Terraform files, CI policy and findings documentation.
- This audit cycle added log-retention rules, a dedicated protected S3 access-log destination and scoped CloudTrail-to-CloudWatch delivery configuration.
- Both bucket policies deny insecure transport. The access-log delivery policy restricts the source bucket and account.
- CloudWatch delivery permissions are scoped to the dedicated log group and expected account CloudTrail streams.
- Historical AWS evidence predates these additions. Their delivery behavior has not been verified through a fresh deployment.

## Open scan findings
- CloudTrail: KMS encryption and SNS log-file delivery notifications.
- Both buckets: KMS encryption, replication, event notifications and incomplete multipart-upload cleanup.
- CloudWatch Logs: customer-managed KMS encryption and retention below one year.

These account for the 12 failures. They remain visible and unsuppressed.

## Recommendations
1. **Priority 1 — Add incomplete multipart-upload cleanup to both lifecycle rules** and rescan; this is the simplest additional configuration remediation.
2. **Priority 1 before claiming live validation — Test the newly added S3 and CloudWatch delivery paths**, confirm scoped IAM permissions and capture sanitized delivery evidence.
3. **Priority 2 — Define retention and key-management requirements**, then resolve or explicitly own the KMS, notification, replication and retention findings.
4. **Priority 2 — Pin direct CI actions to verified commit SHAs** and maintain scanner/provider versions.
5. **Priority 2 — Review monitoring exclusions.** KMS and RDS Data API management events are excluded, and S3 object data events are not selected.

The existing approved banner remains unchanged. No AWS deployment or new runtime claim was made.

## Banner and evidence integrity

The README links an existing `skynet-lab-05.png` banner and the asset is present. No replacement was needed in this portfolio-wide pass. Historical evidence was preserved. Recommendations above remain open unless explicitly described as completed.

## References

- [GitHub Actions security guidance](https://docs.github.com/en/actions/reference/security/secure-use)
- [AWS S3 transport-encryption guidance](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingEncryptionInTransit.html)
- [Kubernetes NetworkPolicy semantics](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

