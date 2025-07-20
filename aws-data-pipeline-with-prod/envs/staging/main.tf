
module "core" {
  source = "../../modules/core"

  aws_region      = var.aws_region
  s3_bucket_name  = var.s3_bucket_name
  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = var.db_password
}
