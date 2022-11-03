# aws provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
}

provider "random" {

}

module "network" {
  source = "./modules/network"

  name = var.network_name
}

# module "dms" {
#   source          = "./modules/dms"
#   dms_bucket_name = var.dms_bucket_name
# }

module "mssql" {
  source     = "./modules/mssql"
  identifier = var.mssql_identifier
  username   = var.mssql_username
  password   = var.mssql_password
  # security_group_id = 
  security_group_id = module.network.security_group.id
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

# resource "aws_s3_bucket" "raw_bucket" {
#   bucket = "grh_raw_bucket_sandbox"
# }
