provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "datascout-state"
    key = "stage/data-stores/postgresql/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "datascout-locks"
    encrypt = true
  }
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.datascout_database.secret_string
  )
}

data "aws_secretsmanager_secret_version" "datascout_database" {
  secret_id = "psql-master-password-stage"
}

resource "aws_db_instance" "postgresql" {
  identifier = "psql"
  allocated_storage = 5
  backup_retention_period = 2
  backup_window = "01:00-01:30"
  maintenance_window = "sun:03:00-sun:03:30"
  multi_az = true
  engine = "postgres"
  instance_class = "db.t2.micro"
  name = "datascout_database"
  username = local.db_creds.username
  password = local.db_creds.password
}

