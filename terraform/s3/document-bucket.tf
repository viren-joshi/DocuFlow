resource "aws_s3_bucket" "docuflow-bucket" {
  bucket = var.docuflow_document_bucket

  tags = {
    Name = "DocumentBucket"
    Project = "DocuFlow"
  }
  force_destroy = true
}

resource "aws_s3_bucket_cors_configuration" "docuflow-document-bucket-cors" {
  bucket = aws_s3_bucket.docuflow-bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
  
}

resource "aws_s3_bucket_policy" "docuflow_bucket_policy" {
  bucket = aws_s3_bucket.docuflow-bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowPresignedUploads",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:PutObject",
        Resource  = "arn:aws:s3:::docuflow-document-bucket/documents/*",
      }
    ]
  })
}


resource "aws_s3_bucket_versioning" "docuflow-bucket-versioning" {
  bucket = aws_s3_bucket.docuflow-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "docuflow-bucket-public-access-block" {
  bucket = aws_s3_bucket.docuflow-bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "document-bucket-lifecycle" {
    bucket = var.docuflow_document_bucket
    rule {
        id = "rule-1"
        status = "Enabled"
        filter {
          prefix = "documents/"
        }
        transition {
          days = 30
          storage_class = "STANDARD_IA"
        }
        transition {
            days = 90
            storage_class = "GLACIER"
        }
        transition {
            days = 365
            storage_class = "DEEP_ARCHIVE"
        }
    }
}