provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "datascout-state"
    key = "global/ecr/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "datascout-locks"
    encrypt = true
  }
}

resource "aws_ecr_repository" "datascout" {
  name  = "datascout"
}
