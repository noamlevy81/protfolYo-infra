output "base_url" {
  value = aws_api_gateway_deployment.application_deployment.invoke_url
}