variable "lab_role_arn" {
    type = string
    description = "ARN of the IAM role for the Lambda function"
    default = "arn:aws:iam::058264209784:role/LabRole"
}

variable "docuflow_init_bucket" {
    type = string
    description = "S3 bucket name for DocuFlow initialization files"
    default = "docuflow-init-bucket"
}

variable "docuflow_document_bucket" {
    type = string
    description = "S3 bucket for DocuFlow Documents"
    default = "docuflow-document-bucket"
}

variable "docuflow_db" {
    type = string
    description = "DynamoDB Table"
    default = "DocuFlowDocuments"
}

variable "docuflow_db_submitted_index_gsi" {
    type = string
    description = "DynamoDB Table - GSI"
    default = "Submitted-Index"
}

variable "docuflow_db_approver_index_gsi" {
    type = string
    description = "DynamoDB Table - GSI"
    default = "Approver-Index"
}

variable "docuflow_lambda_layer_arn" {
    type = string
    description = "ARN of the Lambda layer stored in the init bucket"
    default = ""
}

# variable "vpc_id" {
#     type = string
#     description = "VPC ID where the Lambda function will run"
# }

# variable "lambda_security_group_id" {
#     type = string
#     description = "ID of the security group to be attached to the lambda functions"
# }

# variable "lambda_subnet_ids" {
#     type = list(string)
#     description = "List of Subnet IDs for the lambda functions to be placed"
# }

variable "docuflow_sfn_arn" {
    type = string
    description = "ARN of the docuflow step function"
}

variable "docuflow_user_pool_id" {
  type = string
  description = "Cognito User Pool Id"
}