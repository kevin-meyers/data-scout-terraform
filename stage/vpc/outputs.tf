output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
  description = "The id for the ecs security group."
}

output "lb_sg_id" {
  value = aws_security_group.lb_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "pub_subnet_ids" {
  value = toset([aws_subnet.pub_subnet1.id, aws_subnet.pub_subnet2.id])
  description = "the ids of the public subnets used for ecs."
}

output "db_subnet_group_id" {
  value = aws_db_subnet_group.db_subnet_group.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
