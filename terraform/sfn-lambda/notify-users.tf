resource "aws_lambda_function" "notify-users" {
    role = var.lab_role_arn
    function_name = "notifyUsers"
    handler = "notify_users.lambda_handler"
    runtime = "python3.11"
    timeout = 30

    tags = {
      Project = "DocuFlow"
    }
    s3_bucket = var.docuflow_init_bucket
    s3_key = "lambda-code/notify_users.zip"

    environment {
      variables = {
        DYNAMODB_TABLE = var.docuflow_db
        RESEND_API_KEY = var.resend_api_key
      }
    }

    layers = [ aws_lambda_layer_version.resend_layer.arn ]

    # vpc_config {
    #   # vpc_id = var.vpc_id
    #   subnet_ids = var.lambda_subnet_ids
    #   security_group_ids = [ var.lambda_security_group_id ]
    # }

}

output "lambda-notify-users-arn" {
  value = aws_lambda_function.notify-users.arn
}