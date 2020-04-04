provider "aws" {
  region = "us-west-2"
}

//
//resource "aws_s3_bucket" "b" {
//  bucket = "nl-bucket-test"
//
//  tags = {
//    Name        = "nl-bucket-test"
//  }
//}

//data "archive_file" "lambda_zip" {
//  type          = "zip"
//  source_file   = "test_lambda.py"
//  output_path   = "lambda_function.zip"
//}
//
//resource "aws_lambda_function" "test_lambda" {
//  filename         = "lambda_function.zip"
//  function_name    = "test_lambda"
//  role             = aws_iam_role.lambda_exec_role.arn
//  handler          = var.handler
//  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
//  runtime          = "python3.7"
//}

module "get_lambda" {
  source = "./lambda"

  lambda_name = "test_lambda"
  lambda_handler = var.handler
  lambda_role = aws_iam_role.lambda_exec_role.arn
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "nl-test-role"
  description = "Allows Lambda Function to call AWS services on your behalf."
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}



resource "aws_api_gateway_rest_api" "applicationAPI" {
  name = "test_api"
}

# The API requires at least one "endpoint", or "resource" in AWS terminology.
# The endpoint created here is: /upload-file
resource "aws_api_gateway_resource" "upload_to_s3" {
  rest_api_id = aws_api_gateway_rest_api.applicationAPI.id
  parent_id   = aws_api_gateway_rest_api.applicationAPI.root_resource_id
  path_part   = "upload-file"
}

module "upload-file" {
  source = "./api_method"

  rest_api_id = aws_api_gateway_rest_api.applicationAPI.id
  resource_id = aws_api_gateway_resource.upload_to_s3.id
  method = "GET"
  path = aws_api_gateway_resource.upload_to_s3.path
  lambda_name = module.get_lambda.function_name
  region = var.region
  account_id = var.account_id
  lambda_invoke_arn = module.get_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "application_deployment" {
  depends_on = [
    module.upload-file,
    module.get_lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.applicationAPI.id
  stage_name  = "test"
}
