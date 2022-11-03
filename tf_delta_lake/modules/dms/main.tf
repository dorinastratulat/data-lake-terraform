resource "aws_s3_bucket" "dms_bucket" {
  bucket = var.dms_bucket_name
}
