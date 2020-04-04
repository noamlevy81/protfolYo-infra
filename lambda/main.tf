locals {
  archive_file_name = "${var.lambda_name}.${var.archive_type}"
  archive_file_path = "${var.lambda_archive_prefix}/${local.archive_file_name}"
}

data "archive_file" "lambda_archive" {
  type          = var.archive_type
  source_file   = "${var.lambda_name}.py" # assuming it is python only
  output_path   = local.archive_file_path
}

resource "aws_lambda_function" "test_lambda" {
  filename         = local.archive_file_path
  function_name    = var.lambda_name
  role             = var.lambda_role
  handler          = var.lambda_handler
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256
  runtime          = var.runtime
}