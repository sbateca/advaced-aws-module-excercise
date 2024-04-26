resource "aws_api_gateway_rest_api"  "my_api" {
  name          = "backend-api-${var.environment_name}"
}

resource "aws_api_gateway_resource" "api_backend_gateway" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "backend"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.api_backend_gateway.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.api_backend_gateway.id
  http_method             = aws_api_gateway_method.proxy_root.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.invoke_arn
}


resource "aws_api_gateway_method_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.api_backend_gateway.id
  http_method = aws_api_gateway_method.proxy_root.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.api_backend_gateway.id
  http_method = aws_api_gateway_method.proxy_root.http_method
  status_code = aws_api_gateway_method_response.proxy.status_code

  depends_on = [
    aws_api_gateway_method.proxy_root,
    aws_api_gateway_integration.lambda
  ]
}

resource "aws_api_gateway_deployment" "gw_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
  ]
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = var.environment_name
}

output "url" {
  value = "${aws_api_gateway_deployment.gw_deployment.invoke_url}"
}