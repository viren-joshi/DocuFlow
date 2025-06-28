resource "aws_lambda_function" "evaluate-approval-outcome" {
    role = var.lab_role_arn
    function_name = "evaluateApprovalOutcome"
    handler = "evaluate_approval_outcome.lambda_handler"
    runtime = "python3.11"
    timeout = 30

    s3_bucket = var.docuflow_init_bucket
    s3_key = "lambda-code/evaluate_approval_outcome.zip"

    environment {
      variables = {
        DYNAMODB_TABLE = var.docuflow_db
      }
    }

    tags = {
      Project = "DocuFlow"
    }

    # layers = [ var.docuflow_lambda_layer_arn ]

    # vpc_config {
    #     # vpc_id = var.vpc_id
    #     subnet_ids = var.lambda_subnet_ids
    #     security_group_ids = [ var.lambda_security_group_id ]
    # }
  
}

output "lambda-evaluate-approval-outcome-arn" {
    value = aws_lambda_function.evaluate-approval-outcome.arn
}