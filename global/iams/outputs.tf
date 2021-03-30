output "ecs_agent_name" {
  value = aws_iam_instance_profile.ecs_agent.name
  description = "The name of the iam policy for the ecs agent."
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
