resource "aws_lambda_function" "submit-document" {
    role = var.lab_role_arn
    function_name = "submitDocument"
    handler = "submit_document.lambda_handler"
    runtime = "python3.11"
    timeout = 30

    tags = {
      Project = "DocuFlow"
    }

    s3_bucket = var.docuflow_init_bucket
    s3_key = "lambda-code/submit_document.zip"

    # layers = [ var.docuflow_lambda_layer_arn ]

    # vpc_config {
    #   # vpc_id = var.vpc_id
    #   security_group_ids = [ var.lambda_security_group_id ]
    #   subnet_ids = var.lambda_subnet_ids
    # }

    environment {
      variables = {
        STEP_FUNCTION_ARN = var.docuflow_sfn_arn
        DYNAMODB_TABLE = var.docuflow_db
        USER_POOL_ID = var.docuflow_user_pool_id
      }
    }
}

output "lambda-submit-document-invoke-arn" {
  value = aws_lambda_function.submit-document.invoke_arn
}