resource "aws_lambda_function" "get-submitted-documents" {
    role = var.lab_role_arn
    function_name = "getSubmittedDocuments"
    handler = "get_submitted_documents.lambda_handler"
    runtime = "python3.11"
    timeout = 30

    tags = {
      Project = "DocuFlow"
    }

    s3_bucket = var.docuflow_init_bucket
    s3_key = "lambda-code/get_submitted_documents.zip"

    environment {
      variables = {
        DYNAMODB_TABLE = var.docuflow_db
        SUBMITTED_INDEX_GSI = var.docuflow_db_submitted_index_gsi
        USER_POOL_ID = var.docuflow_user_pool_id
      }
    }

    # layers = [ var.docuflow_lambda_layer_arn ]
    
    # vpc_config {
    #   # vpc_id = var.vpc_id
    #   subnet_ids = var.lambda_subnet_ids
    #   security_group_ids = [ var.lambda_security_group_id ]
    # }
  
}

output "lambda-submitted-documents-invoke-arn" {
  value = aws_lambda_function.get-submitted-documents.invoke_arn
}