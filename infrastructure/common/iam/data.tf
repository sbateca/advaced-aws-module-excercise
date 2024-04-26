# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }
#     effect = "Allow"
#   }
# }

# data "aws_iam_policy_document" "permissions" {
#   statement {
#     actions = [
#       "iam:CreateAccessKey",
#       "iam:DeleteAccessKey",
#       "iam:ListAccessKeys",
#       "iam:UpdateAccessKey"
#     ]
#     resources = [aws_iam_user.user.arn]
#   }

#   statement {
#     actions   = ["ssm:PutParameter"]
#     resources = ["arn:aws:ssm:${var.region}:*:parameter/*testuser*"]
#   }

#   statement {
#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents"
#     ]
#     resources = ["*"]
#   }
# }