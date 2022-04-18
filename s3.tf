module "remote-state-s3-backend" {
  count   = var.backend_enabled ? 1 : 0
  source  = "nozaq/remote-state-s3-backend/aws"
  version = "1.2.0"
  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
  terraform_iam_policy_create = false
}

