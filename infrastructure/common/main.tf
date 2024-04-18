/************* LAMBDA FUNCTION ***********************/

resource "aws_lambda_function" "backend" {
  filename      = "lambda.zip"
  function_name = "backend-lambda-function-${var.environment_name}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main"
  runtime       = "python3.8"
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.backend.invoke_arn
}

/*********************** S3 **********************************/
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "frontend-bucket-${var.environment_name}"
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${"frontend-bucket-${var.environment_name}"}/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_website_configuration" "s3_website_config" {
  bucket = aws_s3_bucket.frontend_bucket.id
  index_document {
    suffix = "index.html"
  }
}

output "bucket_website_url" {
  value = "http://${aws_s3_bucket.frontend_bucket.bucket_domain_name}"
}

/************** API GATEWAY ************************/

resource "aws_api_gateway_rest_api"  "my_api" {
  name          = "backend-api-${var.environment_name}"
}

resource "aws_api_gateway_resource" "api_backend_gateway" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.api_backend_gateway.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.api_backend_gateway.id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.backend.invoke_arn
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

/************* IAM ROLE ***********************/
resource "aws_iam_role" "lambda_role" {
  name = "lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  description = "Policy for Lambda function"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:ListAccessKeys",
          "iam:UpdateAccessKey"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "ssm:PutParameter",
        Resource = "arn:aws:ssm:${var.region}:*:parameter/*testuser*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}