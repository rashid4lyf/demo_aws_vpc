provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "replica"
  region = var.replica_region
}

