

resource "random_id" "id" {
  byte_length = 8
}

resource "aws_secretsmanager_secret" "mssql_pass" {
  name = "${var.secret_prefix}_${random_id.id.hex}"
}

resource "aws_secretsmanager_secret_version" "mssql_pass_val" {
  secret_id = aws_secretsmanager_secret.mssql_pass.id
  secret_string = jsonencode(
    {
      username = aws_db_instance.mssql.username
      password = aws_db_instance.mssql.password
      host     = aws_db_instance.mssql.endpoint
      engine   = "sqlserver"
    }
  )
}

resource "aws_db_subnet_group" "mssql_subnet_group" {

}

resource "aws_db_instance" "mssql" {
  allocated_storage   = var.allocated_storage
  storage_type        = var.storage_type
  engine              = "sqlserver-ex"
  engine_version      = "15.00.4236.7.v1"
  instance_class      = var.instance_class
  identifier          = var.identifier
  username            = var.username
  password            = var.password
  license_model       = "license-included"
  skip_final_snapshot = true
  #   db_subnet_group_name = var.subnet_group_name
  vpc_security_group_ids = [
    var.security_group_id
  ]

  #   publicly_accessible = true
  # instance_class      = "db.m5.large"
  # db_name             = "mydb"
}


