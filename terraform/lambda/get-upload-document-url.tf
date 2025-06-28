resource "aws_lambda_function" "get-upload-document-url" {
    role = var.lab_role_arn
    function_name = "getUploadDocumentUrl"
    handler       = "get_upload_document_url.lambda_handler"
    runtime       = "python3.11"
    timeout = 30

    s3_bucket = var.docuflow_init_bucket
    s3_key    = "lambda-code/get_upload_document_url.zip"

    # layers = [ var.docuflow_lambda_layer_arn ]

    tags = {
      Project = "DocuFlow"
    }

    environment {
      variables = {
        "S3_BUCKET" = var.docuflow_document_bucket
      }
    }

    # vpc_config {
    #     # vpc_id = var.vpc_id
    #     security_group_ids = [ var.lambda_security_group_id ]
    #     subnet_ids = var.lambda_subnet_ids
    # }
}

output "lambda-get-upload-document-url-invoke-arn" {
    value = aws_lambda_function.get-upload-document-url.invoke_arn
}