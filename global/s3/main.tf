provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "datascout-state"
    key = "global/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "datascout-locks"
    encrypt = true
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "datascout-state"

  # Prevent accidental deletion of this s3 bucket
  lifecycle {
    prevent_destroy = true
  }

  # To see revision history
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "datascout-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
