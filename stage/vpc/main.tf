provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "datascout-state"
    key = "stage/vpc/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "datascout-locks"
    encrypt = true
  }
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags       = {
        Name = "Datascout VPC"
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "pub_subnet1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.0.0/17"
    availability_zone = "us-east-2a"
}

resource "aws_subnet" "pub_subnet2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.128.0/17"
    availability_zone = "us-east-2b"
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
}

resource "aws_route_table_association" "route_table_association1" {
    subnet_id = aws_subnet.pub_subnet1.id
    route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "route_table_association2" {
    subnet_id = aws_subnet.pub_subnet2.id
    route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ecs_sg" {
    vpc_id      = aws_vpc.vpc.id

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "rds_sg" {
    vpc_id      = aws_vpc.vpc.id

    ingress {
        protocol        = "tcp"
        from_port       = 5432
        to_port         = 5432
        cidr_blocks     = ["0.0.0.0/0"]
        security_groups = [aws_security_group.ecs_sg.id]
      }
    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
    subnet_ids  = [aws_subnet.pub_subnet1.id, aws_subnet.pub_subnet2.id]
}

