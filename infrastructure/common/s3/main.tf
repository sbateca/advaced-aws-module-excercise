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