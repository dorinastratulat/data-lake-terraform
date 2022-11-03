variable "dms_bucket_name" {
  description = "Name of the S3 bucket for DMS. Must be unique"
  type        = string
}

variable "mssql_identifier" {
  type = string
}
variable "mssql_username" {
  type = string
}
variable "mssql_password" {
  type = string
}

variable "mssql_secret_prefix" {
  type = string
}

variable "network_name" {
  type = string
}
