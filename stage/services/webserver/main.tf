provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket         = "datascout-state"
    key            = "stage/services/webserver/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "datascout-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "datascout-state"
    key    = "stage/data-stores/postgresql/terraform.tfstate"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "iams" {
  backend = "s3"
  config = {
    bucket = "datascout-state"
    key    = "global/iams/terraform.tfstate"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "datascout-state"
    key    = "stage/vpc/terraform.tfstate"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket = "datascout-state"
    key    = "global/ecr/terraform.tfstate"
    region = "us-east-2"
  }
}

data "template_file" "task_definition_template" {
  template = file("${path.module}/task_definition.json.tpl")
  vars = {
    repo_url = data.terraform_remote_state.ecr.outputs.repo_url
  }
}

resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = "ami-094d4d00fd7462815"
  iam_instance_profile = data.terraform_remote_state.iams.outputs.ecs_agent_name
  security_groups      = [data.terraform_remote_state.vpc.outputs.ecs_sg_id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config"
  instance_type        = "t2.micro"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
  name                      = "asg"
  vpc_zone_identifier       = [data.terraform_remote_state.vpc.outputs.pub_subnet_id1, data.terraform_remote_state.vpc.outputs.pub_subnet_id2]
  launch_configuration      = aws_launch_configuration.ecs_launch_config.name
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 10
  health_check_grace_period = 300
  health_check_type         = "EC2"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "datascout-ecs"
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "datascout"
  container_definitions = data.template_file.task_definition_template.rendered
}

resource "aws_ecs_service" "datascout" {
  name            = "datascout-worker"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
}
