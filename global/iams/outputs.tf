output "ecs_agent_name" {
  value = aws_iam_instance_profile.ecs_agent.name
  description = "The name of the iam policy for the ecs agent."
}
