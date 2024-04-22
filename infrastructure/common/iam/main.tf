resource "aws_iam_role" "lambda_role" {
  name = "lambda-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
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

resource "aws_iam_role_policy" "permissions" {
  name   = "iam-lambda-permissions"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.permissions.json
}

resource "aws_iam_user" "user" {
  name = "testuser"
  path = "/system/"
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}