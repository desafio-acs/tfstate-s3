provider "aws" {
  region = "us-east-2"
}

##############################
# S3 Bucket para Terraform State
##############################
resource "aws_s3_bucket" "terraform_state" {
  bucket = "samuel-desafio-acs-tfstate-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    prevent_destroy = true
  }
}

# Criptografia padrão no bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Versionamento habilitado (boa prática p/ state rollback)
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

##############################
# DynamoDB Table para lock
##############################
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

##############################
# Identity
##############################
data "aws_caller_identity" "current" {}
