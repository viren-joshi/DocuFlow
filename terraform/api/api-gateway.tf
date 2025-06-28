resource "aws_cloudwatch_log_group" "docuflow-api-logs" {
  name              = "/aws/apigateway/docuflow-api"
  retention_in_days = 14
}

resource "aws_apigatewayv2_api" "docuflow-api" {
    name          = "docuflow-http-api"
    protocol_type = "HTTP"

    cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["*"]
    expose_headers = []
    max_age        = 3600
  }
}

resource "aws_apigatewayv2_authorizer" "cognito_auth" {
    api_id          = aws_apigatewayv2_api.docuflow-api.id
    name            = "cognito-authorizer"
    authorizer_type = "JWT"

    identity_sources = ["$request.header.Authorization"]

    jwt_configuration {
        audience = [var.web_client_id]
        issuer   = "https://${var.user_pool_endpoint}"
    }
}

# getUploadDocumentUrl
resource "aws_apigatewayv2_integration" "upload-document-url-integration" {
    api_id           = aws_apigatewayv2_api.docuflow-api.id
    credentials_arn = var.lab_role_arn
    integration_type = "AWS_PROXY"
    integration_uri  = var.lambda-get-upload-document-url-invoke-arn
    integration_method = "POST"
    payload_format_version = "2.0"
}
resource "aws_apigatewayv2_route" "upload-document-url-route" {
    api_id    = aws_apigatewayv2_api.docuflow-api.id
    route_key = "POST /getUploadDocumentUrl"
    target    = "integrations/${aws_apigatewayv2_integration.upload-document-url-integration.id}"
    authorizer_id = aws_apigatewayv2_authorizer.cognito_auth.id
    authorization_type = "JWT"
}

# getViewDocumentUrl
resource "aws_apigatewayv2_integration" "view-document-url-integration" {
    api_id           = aws_apigatewayv2_api.docuflow-api.id
    credentials_arn = var.lab_role_arn
    integration_type = "AWS_PROXY"
    integration_uri  = var.lambda-get-view-document-url-invoke-arn
    integration_method = "POST"
    payload_format_version = "2.0"
}
resource "aws_apigatewayv2_route" "view-document-url-route" {
    api_id    = aws_apigatewayv2_api.docuflow-api.id
    route_key = "POST /getViewDocumentUrl"
    target    = "integrations/${aws_apigatewayv2_integration.view-document-url-integration.id}"
    authorizer_id = aws_apigatewayv2_authorizer.cognito_auth.id
    authorization_type = "JWT"
}

# submitDocument
resource "aws_apigatewayv2_integration" "submit-document-integration" {
    api_id = aws_apigatewayv2_api.docuflow-api.id
    credentials_arn = var.lab_role_arn
    integration_type = "AWS_PROXY"
    integration_uri = var.lambda-submit-document-invoke-arn
    integration_method = "POST"
    payload_format_version = "2.0"
}
resource "aws_apigatewayv2_route" "submit-document-route" {
    api_id = aws_apigatewayv2_api.docuflow-api.id
    route_key = "POST /submitDocument"
    target = "integrations/${aws_apigatewayv2_integration.submit-document-integration.id}"
    authorizer_id = aws_apigatewayv2_authorizer.cognito_auth.id
    authorization_type = "JWT"
}

# approveDocument
resource "aws_apigatewayv2_integration" "approve-document-integration" {
    api_id = aws_apigatewayv2_api.docuflow-api.id
    credentials_arn = var.lab_role_arn
    integration_type = "AWS_PROXY"
    integration_uri = var.lambda-approve-document-invoke-arn
    integration_method = "POST"
    payload_format_version = "2.0"
}
resource "aws_apigatewayv2_route" "approve-document-route" {
    api_id = aws_apigatewayv2_api.docuflow-api.id
    route_key = "POST /approveDocument"
    target = "integrations/${aws_apigatewayv2_integration.approve-document-integration.id}"
    authorizer_id = aws_apigatewayv2_authorizer.cognito_auth.id
    authorization_type = "JWT"
}

# getSubmittedDocuments
resource "aws_apigatewayv2_integration" "submitted-documents-integration" {
    api_id = aws_apigatewayv2_api.docuflow-api.id
    credentials_arn = var.lab_role_arn
    integration_type = "AWS_PROXY"
    integration_uri = var.lambda-submitted-documents-invoke-arn
    integration_method = "POST"
    payload_format_version = "2.0"
}
resource "aws_apigatewayv2_route" "submitted-documents-route" {
    api_id = aws_apigatewayv2_api.docuflow-api.id
    route_key = "POST /getSubmittedDocuments"
    target = "integrations/${aws_apigatewayv2_integration.submitted-documents-integration.id}"
    authorizer_id = aws_apigatewayv2_authorizer.cognito_auth.id
    authorization_type = "JWT"
}

# getApprovalDocuments
resource "aws_apigatewayv2_integration" "approval-documents-integration" {
    api_id = aws_apigatewayv2_api.docuflow-api.id
    credentials_arn = var.lab_role_arn
    integration_type = "AWS_PROXY"
    integration_uri = var.lambda-approval-documents-invoke-arn
    integration_method = "POST"
    payload_format_version = "2.0"
}
resource "aws_apigatewayv2_route" "approval-documents-route" {
    api_id = aws_apigatewayv2_api.docuflow-api.id
    route_key = "POST /getApprovalDocuments"
    target = "integrations/${aws_apigatewayv2_integration.approval-documents-integration.id}"
    authorizer_id = aws_apigatewayv2_authorizer.cognito_auth.id
    authorization_type = "JWT"
}


resource "aws_apigatewayv2_stage" "prod" {
    api_id      = aws_apigatewayv2_api.docuflow-api.id
    name        = "prod"
    auto_deploy = true

    access_log_settings {
        destination_arn = aws_cloudwatch_log_group.docuflow-api-logs.arn
        format = jsonencode({ "requestId": "$context.requestId", "ip": "$context.identity.sourceIp", "caller": "$context.identity.caller", "user": "$context.identity.user", "userAgent": "$context.identity.userAgent", "requestTime": "$context.requestTime", "httpMethod": "$context.httpMethod", "routeKey": "$context.routeKey", "status": "$context.status", "protocol": "$context.protocol", "responseLength": "$context.responseLength", "domainName": "$context.domainName", "errorMessage": "$context.error.message", "errorResponseType": "$context.error.responseType", "integrationErrorMessage": "$context.integration.error", "integrationStatus": "$context.integration.status", "integrationLatency": "$context.integration.latency", "integrationRequestId": "$context.integration.requestId", "authorizerError": "$context.authorizer.error", "authorizerPrincipalId": "$context.authorizer.principalId", "authorizerClaims": "$context.authorizer.claims", "path": "$context.path", "accountId": "$context.accountId", "apiId": "$context.apiId", "stage": "$context.stage", "responseLatency": "$context.responseLatency" })
    }
    default_route_settings {
        throttling_burst_limit = 5
        throttling_rate_limit = 10
    }

}
