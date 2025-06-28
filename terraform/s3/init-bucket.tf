# This file manages the init-bucket for DocuFlow, it does not create 
# the bucket, it imports the bucket. Hence, run this command before applying:
# `terraform import aws_s3_bucket.init-bucket docuflow-init-bucket`

resource "aws_s3_bucket" "init-bucket" {
    bucket = var.docuflow_init_bucket
    force_destroy = false

    tags = {
      Project = "DocuFlow"
    }
}

# Enabling versioning for the initialization bucket
# resource "aws_s3_bucket_versioning" "init-bucket-versioning" {
#     bucket = aws_s3_bucket.init-bucket.id
#     versioning_configuration {
#         status = "Enabled"
#     }
# }

# Keeping the bucket private
resource "aws_s3_bucket_public_access_block" "init-bucket-public-access-block" {
    bucket = aws_s3_bucket.init-bucket.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "init-bucket-lifecycle" {
    bucket = aws_s3_bucket.init-bucket.id

    rule {
        id = "rule-1"
        status = "Enabled"
        filter {
          prefix = "lambda-layers/"
        }
        # TODO: Figure out the way to remove older versions of lambda layers
        noncurrent_version_expiration {
            noncurrent_days = 90
        } 
    }
    rule {
        id = "rule-2"
        status = "Enabled"
        filter {
          prefix = "lambda-code/"
        }
        noncurrent_version_expiration {
          noncurrent_days = 90
        }
    }
  
}