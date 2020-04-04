output "function_name" {
  value = var.lambda_name
}

output "invoke_arn" {
  value = aws_lambda_function.test_lambda.invoke_arn
}