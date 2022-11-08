variable "dms_bucket_name" {
  description = "Name of the S3 bucket for DMS. Must be unique"
  type        = string
}

variable "base_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  type = set(string)
}

variable "db_secrets_arn" {
  type = string
}

variable "security_group_id" {
  type = string
}
