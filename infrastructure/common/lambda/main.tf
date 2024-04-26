resource "aws_lambda_function" "backend" {
  filename      = "lambda.zip"
  function_name = "backend-lambda-function-${var.environment_name}"
  role          = var.lambda_role_arn
  handler       = "main.handler"
  runtime       = "python3.8"
  source_code_hash = sha256(filebase64("lambda.zip"))
}

resource "aws_lambda_permission" "permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.backend.invoke_arn
}