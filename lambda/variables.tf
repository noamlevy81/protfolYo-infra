variable "archive_type" {
  description = "type of archive file"
  default = "zip"
}

//variable "archive_source_file" {
//  description = "name of the file to archive"
//}

variable "lambda_name" {
  description = "name of the lambda"
}

variable "lambda_handler" {
  description = "the handler function"
}

variable "lambda_role" {
  description = "arn of the lambda role"
}

variable "runtime" {
  description = "lambda runtime"
  default = "python3.7"
}

variable "lambda_archive_prefix" {
  description = "path to lambdas archive"
  default = "./lambdas"
}