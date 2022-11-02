# aws provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
}

# resource "aws_db_instance" "grh_mssql" {
#   allocated_storage   = 20
#   storage_type        = "gp2"
#   engine              = "sqlserver-ex"
#   engine_version      = "15.00.4236.7.v1"
#   instance_class      = "db.t3.small"
#   identifier          = "grh-mssql-sandbox"
#   username            = "admin"
#   password            = "ma1nus3r"
#   license_model       = "license-included"
#   skip_final_snapshot = true
#   # instance_class      = "db.m5.large"
#   # db_name             = "mydb"
# }

resource "aws_s3_bucket" "raw_bucket" {
  bucket = "grh_raw_bucket_sandbox"
}
