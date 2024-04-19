resource "aws_lambda_function" "backend" {
  filename      = "lambda.zip"
  function_name = "backend-lambda-function-${var.environment_name}"
  role          = var.lambda_role_arn
  handler       = "main"
  runtime       = "python3.8"
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.backend.invoke_arn
}