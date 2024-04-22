data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/app"
  output_path = "${path.module}/../../../lambda.zip"
}
