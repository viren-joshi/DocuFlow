resource "aws_lambda_function" "implicit-rejection" {
    role = var.lab_role_arn
    function_name = "implicitRejection"
    handler = "implicit_rejection.lambda_handler"
    runtime = "python3.11"

    tags = {
      Project = "DocuFlow"
    }

    s3_bucket = var.docuflow_init_bucket
    s3_key = "lambda-code/implicit_rejection.zip"

    environment {
      variables = {
        DYNAMODB_TABLE = var.docuflow_db
        
      }
    }

    # layers = [ var.docuflow_lambda_layer_arn ]

    # vpc_config {
    #     # vpc_id = var.vpc_id
    #     subnet_ids = var.lambda_subnet_ids
    #     security_group_ids = [ var.lambda_security_group_id ]
    # }

}

output "lambda-implicit-rejection-arn" {
    value = aws_lambda_function.implicit-rejection.arn
}