resource "aws_api_gateway_method" "request_method" {
  rest_api_id   = var.rest_api_id
  resource_id   = var.resource_id
  http_method   = var.method
  authorization = "NONE"
}

# GET /upload-file => POST lambda
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = var.resource_id
  http_method             = aws_api_gateway_method.request_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

# lambda => GET response
resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_integration.integration.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# Response for: GET /upload-file
resource "aws_api_gateway_integration_response" "response_method_integration" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method_response.response_method.http_method
  status_code = aws_api_gateway_method_response.response_method.status_code

  response_templates = {
    "application/json" = ""
  }
}


resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = var.lambda_name
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:476956259333:${var.rest_api_id}/*/${var.method}${var.path}"
}