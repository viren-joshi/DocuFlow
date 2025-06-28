resource "aws_lambda_function" "approve-document" {
    role = var.lab_role_arn
    function_name = "approveDocument"
    handler = "approve_document.lambda_handler"
    runtime = "python3.11"
    timeout = 30

    tags = {
      Project = "DocuFlow"
    }

    s3_bucket = var.docuflow_init_bucket
    s3_key = "lambda-code/approve_document.zip"

    environment {
      variables = {
        DYNAMODB_TABLE = var.docuflow_db
      }
    }

    # layers = [ var.docuflow_lambda_layer_arn ]

    # vpc_config {
    #   # vpc_id = var.vpc_id
    #   subnet_ids = var.lambda_subnet_ids
    #   security_group_ids = [ var.lambda_security_group_id ]
    # }
}

output "lambda-approve-document-invoke-arn" {
  value = aws_lambda_function.approve-document.invoke_arn
}