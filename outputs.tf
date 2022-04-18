output "state_bucket" {
  value = var.backend_enabled ?  module.remote-state-s3-backend.state_bucket.bucket : ""
}

output "dynamodb_table" {
  value = var.backend_enabled ? module.remote-state-s3-backend.dynamodb_table.id : ""
}

output "kms_key" {
  value = var.backend_enabled ? module.remote-state-s3-backend.kms_key.id: ""
}
