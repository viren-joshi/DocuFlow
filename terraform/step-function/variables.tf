variable "lab_role_arn" {
    type = string
    description = "ARN of the IAM role for the Lambda function"
    default = "arn:aws:iam::058264209784:role/LabRole"
}

variable "lambda-notify-users-arn" {
    type = string
    description = "ARN of the lambda function that notifies the approvers"
}

variable "lambda-implicit-rejection-arn" {
    type = string
    description = "ARN of the lambda function that implicitly rejects the document in case of error"
}

variable "lambda-evaluate-approval-outcome-arn" {
    type = string
    description = "ARN fo the lambda function that evaluates the final outcome of the document"
}