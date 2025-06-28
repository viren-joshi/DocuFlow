resource "aws_s3_bucket" "docuflow-fronend-bucket" {
  bucket = var.frontend_bucket_name

  tags = {
    Name = "DocuFlow Frontend Bucket"
    Project = "DocuFlow"
  }
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "docuflow-fronend-bucket-website" {
  bucket = aws_s3_bucket.docuflow-fronend-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
  
}

resource "aws_s3_bucket_public_access_block" "docuflow-fronend-bucket-public-access-block" {
  bucket = aws_s3_bucket.docuflow-fronend-bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
  
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.docuflow-fronend-bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.docuflow-fronend-bucket.arn}/*"
      }
    ]
  })
}


output "frontend_bucket_arn" {
  value = aws_s3_bucket.docuflow-bucket.arn
}
