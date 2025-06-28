resource "aws_cognito_user_pool" "docuflow-user-pool" {
  name = "DocuFlowUserPool"

  username_attributes       = ["email"]
  auto_verified_attributes  = ["email"]

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_client" "web-client" {
  name = "DocuFlowWebClient"
  user_pool_id = aws_cognito_user_pool.docuflow-user-pool.id
  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

output "cognito_user_pool_endpoint" {
  value = aws_cognito_user_pool.docuflow-user-pool.endpoint
}

output "docuflow_user_pool_id" {
  value = aws_cognito_user_pool.docuflow-user-pool.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.web-client.id
}
