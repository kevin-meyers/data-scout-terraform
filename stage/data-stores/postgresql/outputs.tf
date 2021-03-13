output "address" {
  value = aws_db_instance.postgresql.address
  description = "Connect to the main datascout database at this endpoint."
}

output "port" {
  value = aws_db_instance.postgresql.port
  description = "The port the main datascount database is listening on."
}
