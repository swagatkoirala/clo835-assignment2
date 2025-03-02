output "instance_public_ip_address" {
  value = aws_instance.amazon_linux.public_ip
}

output "sql_repository_uri" {
  value = aws_ecr_repository.sql_repository.repository_url
}

output "webapp_repository_uri" {
  value = aws_ecr_repository.webapp_repository.repository_url
}