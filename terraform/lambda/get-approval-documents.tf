resource "aws_lambda_function" "get-approval-documents" {
    role = var.lab_role_arn
    function_name = "getApprovalDocuments"
    handler = "get_approval_documents.lambda_handler"
    runtime = "python3.11"
    timeout = 30

    tags = {
      Project = "DocuFlow"
    }

    s3_bucket = var.docuflow_init_bucket
    s3_key = "lambda-code/get_approval_documents.zip"

    environment {
      variables = {
        DYNAMODB_TABLE = var.docuflow_db
        APPROVER_INDEX_GSI = var.docuflow_db_approver_index_gsi
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

output "lambda-approval-documents-invoke-lambda" {
  value = aws_lambda_function.get-approval-documents.invoke_arn
}