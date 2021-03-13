output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
  description = "The id for the ecs security group."
}

output "pub_subnet_id1" {
  value = aws_subnet.pub_subnet1.id
  description = "the id of the first public subnet used for ecs."
}

output "pub_subnet_id2" {
  value = aws_subnet.pub_subnet2.id
  description = "the id of the second public subnet used for ecs."
}

output "db_subnet_group_id" {
  value = aws_db_subnet_group.db_subnet_group.id
}
