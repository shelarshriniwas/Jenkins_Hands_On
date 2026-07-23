#############################################
# S3 Bucket
#############################################

resource "aws_s3_bucket" "bucket" {

  bucket = "my-terraform-demo-bucket-123456"

  tags = {
    Name        = "my-terraform-demo-bucket"
    Environment = "dev"
    Project     = "terraform"
  }
}

#############################################
# Bucket Versioning
#############################################

resource "aws_s3_bucket_versioning" "versioning" {

  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {

    status = "Enabled"

  }
}

#############################################
# Server Side Encryption
#############################################

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {

  bucket = aws_s3_bucket.bucket.id

  rule {

    apply_server_side_encryption_by_default {

      sse_algorithm = "AES256"

    }

  }
}

#############################################
# Block Public Access
#############################################

resource "aws_s3_bucket_public_access_block" "public_access" {

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true

}

#############################################
# Bucket Ownership Controls
#############################################

resource "aws_s3_bucket_ownership_controls" "ownership" {

  bucket = aws_s3_bucket.bucket.id

  rule {

    object_ownership = "BucketOwnerPreferred"

  }
}

#############################################
# Bucket ACL
#############################################

resource "aws_s3_bucket_acl" "acl" {

  depends_on = [
    aws_s3_bucket_ownership_controls.ownership
  ]

  bucket = aws_s3_bucket.bucket.id

  acl = "private"
}

#############################################
# Bucket Policy
#############################################

resource "aws_s3_bucket_policy" "policy" {

  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Sid = "AllowSSLRequestsOnly"

        Effect = "Deny"

        Principal = "*"

        Action = "s3:*"

        Resource = [

          aws_s3_bucket.bucket.arn,
          "${aws_s3_bucket.bucket.arn}/*"

        ]

        Condition = {

          Bool = {

            "aws:SecureTransport" = "false"

          }

        }

      }

    ]

  })
}

#############################################
# Lifecycle Configuration
#############################################

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {

  bucket = aws_s3_bucket.bucket.id

  rule {

    id = "log-lifecycle"

    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    transition {

      days          = 30
      storage_class = "STANDARD_IA"

    }

    transition {

      days          = 90
      storage_class = "GLACIER"

    }

    expiration {

      days = 365

    }

  }
}

#############################################
# Bucket Logging
#############################################

resource "aws_s3_bucket_logging" "logging" {

  bucket = aws_s3_bucket.bucket.id

  target_bucket = aws_s3_bucket.logs.id

  target_prefix = "access-logs/"
}

#############################################
# Log Bucket
#############################################

resource "aws_s3_bucket" "logs" {

  bucket = "my-terraform-log-bucket-123456"

  tags = {
    Name = "log-bucket"
  }
}

#############################################
# Outputs
#############################################

output "bucket_name" {

  value = aws_s3_bucket.bucket.bucket

}

output "bucket_arn" {

  value = aws_s3_bucket.bucket.arn

}