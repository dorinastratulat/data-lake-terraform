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
  name       = "mssql_subnet_group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "mssql" {
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  engine               = "sqlserver-se"
  engine_version       = "15.00.4236.7.v1"
  instance_class       = var.instance_class
  identifier           = var.identifier
  username             = var.username
  password             = var.password
  license_model        = "license-included"
  skip_final_snapshot  = true
  publicly_accessible  = true
  db_subnet_group_name = aws_db_subnet_group.mssql_subnet_group.name
  vpc_security_group_ids = [
    var.security_group_id
  ]

  #   publicly_accessible = true
  # instance_class      = "db.m5.large"
  # db_name             = "mydb"
}

resource "null_resource" "seed_db" {
  depends_on = [
    aws_db_instance.mssql
  ]

  # triggers = {
  #   always_run = timestamp()
  # }

  provisioner "local-exec" {
    command     = "./dbtool destroy && ./dbtool init && ./dbtool seed 5"
    interpreter = ["bash", "-c"]

    environment = {
      SQL_ENDPOINT = aws_db_instance.mssql.endpoint
    }
  }


}
