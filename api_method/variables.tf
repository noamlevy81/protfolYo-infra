variable "rest_api_id" {
  description = "The ID of the associated REST API"
}

variable "resource_id" {
  description = "The API resource ID"
}

variable "method" {
  description = "The HTTP method"
  default     = "GET"
}

variable "path" {
  description = "The API resource path"
}

variable "lambda_name" {
  description = "The lambda name to invoke"
}

variable "lambda_invoke_arn" {
  description = "lambda function invocation arn"
}

variable "region" {
  description = "The AWS region, e.g., eu-west-1"

}

variable "account_id" {
  description = "The AWS account ID"
  default = "476956259333"
}