resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "frontend-bucket-${var.environment_name}"
}


resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  bucket = aws_s3_bucket.frontend_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "acl" {
  bucket     = aws_s3_bucket.frontend_bucket.id
  acl        = "private"
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_ownership_controls,
  ]
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