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

resource "aws_iam_user" "user" {
  name = "user"
  path = "/system/"
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}