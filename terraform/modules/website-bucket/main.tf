# Create the S3 bucket
# TFSec rules ignored because you can't encrypt an S3 bucket used as a website without Cloudfront
# also kinda pointless for a public bucket sending data over HTTP
# tfsec:ignore:aws-s3-encryption-customer-key
# tfsec:ignore:aws-s3-enable-bucket-encryption
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.site_name
}

# Create a public access block that disables blocking public access
resource "aws_s3_bucket_public_access_block" "website_public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls = true
  # Allow public policy so that the bucket can be used as a website
  # tfsec:ignore:aws-s3-block-public-policy
  block_public_policy = false
  ignore_public_acls  = true
  # Allow public buckets so that the bucket can be used as a website
  # tfsec:ignore:aws-s3-no-public-buckets
  restrict_public_buckets = false
}

# Configure bucket policy to make the bucket objects publicly readable
resource "aws_s3_bucket_policy" "site_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

# Enable bucket versioning
resource "aws_s3_bucket_versioning" "website_versioning" {
  bucket = aws_s3_bucket.website_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable bucket logging
resource "aws_s3_bucket_logging" "website_logging" {
  bucket = aws_s3_bucket.website_bucket.id

  target_bucket = var.log_bucket_id
  target_prefix = var.site_name
}

# Set the website endpoints
resource "aws_s3_bucket_website_configuration" "sitemap" {
  bucket = aws_s3_bucket.website_bucket.id
  index_document {
    suffix = var.index_file_name
  }
  error_document {
    key = var.error_file_name
  }
}

# Upload static website files to the S3 bucket
resource "aws_s3_bucket_object" "website_files" {
  for_each = fileset(var.path_to_site_files, var.site_files_pattern)

  bucket = aws_s3_bucket.website_bucket.id
  key    = each.value
  source = "${var.path_to_site_files}/${each.value}"
  # Set the correct Content-Type based on the file extension
  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
    "json" = "application/json"
    "txt"  = "text/plain"
  }, regex("[^.]+$", each.value), "application/octet-stream")
}

# Output the S3 bucket website URL
output "website_url" {
  value = aws_s3_bucket_website_configuration.sitemap.website_endpoint
}
