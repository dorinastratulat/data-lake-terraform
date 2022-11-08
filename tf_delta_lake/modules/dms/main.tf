resource "aws_s3_bucket" "dms_bucket" {
  bucket = var.dms_bucket_name

}

# aws security group that allows all ingress and egress traffic
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.base_name}_allow_all"
  }
}

# aws subnet group for dms
resource "aws_dms_replication_subnet_group" "dms_subnet_group" {
  replication_subnet_group_id          = "${var.base_name}-dms-subnet-group"
  replication_subnet_group_description = "Subnet group for DMS"
  subnet_ids                           = var.subnet_ids
}

data "aws_iam_policy_document" "secrets_manager_policy" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:*",
    ]

    resources = [
      var.db_secrets_arn,
      "*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:*",
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "s3_admin_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.dms_bucket.arn,
    ]
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "dms.ca-central-1.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "dms_role" {
  name               = "${var.base_name}-dms-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  # assume_role_policy = data.aws_iam_policy_document.secrets_manager_policy.json

  inline_policy {
    name   = "${var.base_name}_dms_secrets_manager_policy"
    policy = data.aws_iam_policy_document.secrets_manager_policy.json
  }

  inline_policy {
    name   = "${var.base_name}_dms_s3_admin_policy"
    policy = data.aws_iam_policy_document.s3_admin_policy.json
  }
}

resource "aws_dms_endpoint" "dms_source_endpoint" {
  endpoint_id   = "${var.base_name}-dms-source-endpoint"
  endpoint_type = "source"
  engine_name   = "sqlserver"
  # secrets_manager_access_role_arn = aws_iam_role.dms_role.arn
  # secrets_manager_arn             = var.db_secrets_arn
  username = "admin"
  password = "ma1nus3r"

  database_name = "test"
}

resource "aws_dms_endpoint" "dms_target_endpoint" {
  endpoint_id   = "${var.base_name}-dms-target-endpoint"
  endpoint_type = "target"
  engine_name   = "s3"

  s3_settings {
    bucket_name             = aws_s3_bucket.dms_bucket.bucket
    service_access_role_arn = aws_iam_role.dms_role.arn
    timestamp_column_name   = "timestamp"
  }
}


resource "aws_dms_replication_instance" "dms_instance" {

  allocated_storage           = 20
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  availability_zone           = "ca-central-1a"
  engine_version              = "3.4.7"
  publicly_accessible         = true
  multi_az                    = false
  replication_instance_class  = "dms.t2.micro"
  replication_instance_id     = "${var.base_name}-dms-replication-instance"
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_subnet_group.id
  vpc_security_group_ids      = [aws_security_group.allow_all.id, var.security_group_id]

}

# resource "aws_dms_replication_task" "dms_replication_task" {

# }
