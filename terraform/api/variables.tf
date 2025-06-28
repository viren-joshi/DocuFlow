variable "lab_role_arn" {
    type = string
    description = "ARN of the IAM role for the Lambda function"
    default = "arn:aws:iam::058264209784:role/LabRole"
}

variable "web_client_id" {
    type = string
    description = "Client Application ID"
}

variable "user_pool_endpoint" {
    type = string
    description = "User Pool Endpoint"
}

variable "lambda-get-upload-document-url-invoke-arn" {
    type = string
    description = "Invoke ARN for lambda function that gets Pre-Signed URLs for document upload"
}

variable "lambda-get-view-document-url-invoke-arn" {
    type = string
    description = "Invoke ARN for lambda function that gets Pre-Signed URLs for viewing documents"
}

variable "lambda-submit-document-invoke-arn" {
    type = string
    description = "Invoke ARN for lambda function that triggers the DocuFlow SFN"
}

variable "lambda-approve-document-invoke-arn" {
    type = string
    description = "Invoke ARN for lambda function that approves/rejects a document"
}

variable "lambda-submitted-documents-invoke-arn" {
    type = string
    description = "Invoke ARN for lambda function that get documents submitted for approval"
}

variable "lambda-approval-documents-invoke-arn" {
    type = string
    description = "Invoke ARN for lambda functions that are to be approved"
}