# the cloud provider we want Terraform to work with
provider "aws" {
  region = "us-west-2"
}

# our bucket in s3
resource "aws_s3_bucket" "b" {
  bucket = "nl-bucket-test"

  acl = "public-read-write"
  tags = {
    Name        = "nl-bucket-test"
  }
}

// creates lambda for the post request "lambda_handler" is the function entry point
module "post_lambda" {
  source = "./lambda"

  lambda_name = "upload_archive_lambda"
  lambda_handler = "upload_archive_lambda.handler"
  lambda_role = aws_iam_role.lambda_exec_role.arn
}

# dont spend your time on roles and policies - in general it grants permissions to services to comunicate with each other
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

resource "aws_iam_role_policy" "lambda_s3_permission" {
  role = aws_iam_role.lambda_exec_role.id
  policy = <<EOF
{
"Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": "*"
        }
    ]
}
EOF
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

# creates the end point in the api. the end point defined in the above resource
module "upload-file-post" {
  source = "./api_method"

  rest_api_id = aws_api_gateway_rest_api.applicationAPI.id
  resource_id = aws_api_gateway_resource.upload_to_s3.id
  method = "POST"
  path = aws_api_gateway_resource.upload_to_s3.path
  lambda_name = module.post_lambda.function_name
  region = var.region
  account_id = var.account_id
  lambda_invoke_arn = module.post_lambda.invoke_arn
}

// the commented resources bellow are what we created together

//module "upload-file-get" {
//  source = "./api_method"
//
//  rest_api_id = aws_api_gateway_rest_api.applicationAPI.id
//  resource_id = aws_api_gateway_resource.upload_to_s3.id
//  method = "GET"
//  path = aws_api_gateway_resource.upload_to_s3.path
//  lambda_name = module.get_lambda.function_name
//  region = var.region
//  account_id = var.account_id
//  lambda_invoke_arn = module.get_lambda.invoke_arn
//}
//
//resource "aws_iam_role" "lambda_exec_role_get" {
//  name = "nl-test-role-1"
//  description = "Allows Lambda Function to call AWS services on your behalf."
//  assume_role_policy = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": "sts:AssumeRole",
//      "Principal": {
//        "Service": "lambda.amazonaws.com"
//      },
//      "Effect": "Allow",
//      "Sid": ""
//    }
//  ]
//}
//POLICY
//}
//module "get_lambda" {
//  source = "./lambda"
//
//  lambda_name = "getRequest"
//  lambda_handler = "getRequest.handler_get"
//  lambda_role = aws_iam_role.lambda_exec_role_get.arn
//}



resource "aws_api_gateway_deployment" "application_deployment" {
  depends_on = [
    module.upload-file-post
    ]

  rest_api_id = aws_api_gateway_rest_api.applicationAPI.id
  stage_name  = "test"
}
