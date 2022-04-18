variable "region" {
  description = "AWS Region"
  default     = "eu-west-1"
}

variable "replica_region" {
  description = "Region in which S3 bucket to be replicated."
  default     = "eu-west-2"

}

variable "cidr_block" {
  type        = string
  description = "VPC cidr block. Example: 10.0.0.0/16"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "backend_enabled" {
  type    = bool
  default = false

}
