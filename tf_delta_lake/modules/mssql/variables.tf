variable "allocated_storage" {
  description = "The allocated storage in gibibytes"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "One of standard | gp2 | io1"
  type        = string
  default     = "gp2"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.small"
}

variable "identifier" {
  description = "The name of the RDS instance"
  type        = string
}


variable "username" {
  description = "The username for the master DB user"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "The password for the master DB user"
  type        = string
  default     = "ma1nus3r"
}

variable "secret_prefix" {
  description = "The prefix for the secret name"
  type        = string
  default     = "mssql_pass"
}

variable "security_group_id" {
  description = "The security group id for the RDS instance"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet id for the RDS subnet group"
  type        = set(string)
}
