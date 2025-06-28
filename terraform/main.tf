# module "docuflow-vpc" {
#     source = "./vpc"
# }

module "s3-buckets" {
    source = "./s3/"
}

module "cognito" {
    source = "./cognito"
}

module "sfn-lambda-functions" {
    source = "./sfn-lambda"

    # vpc_id = module.docuflow-vpc.vpc_id
    # lambda_security_group_id = module.docuflow-vpc.lambda_security_group_id
    # lambda_subnet_ids = module.docuflow-vpc.private_subnet_ids

    depends_on = [ 
        # module.docuflow-vpc, 
        module.s3-buckets 
    ]
}


module "docuflow-sfn" {
    source = "./step-function"

    lambda-notify-users-arn = module.sfn-lambda-functions.lambda-notify-users-arn
    lambda-implicit-rejection-arn = module.sfn-lambda-functions.lambda-implicit-rejection-arn
    lambda-evaluate-approval-outcome-arn = module.sfn-lambda-functions.lambda-evaluate-approval-outcome-arn

    depends_on = [ module.sfn-lambda-functions ]
}

module "lambda-functions" {
    source = "./lambda"

    # vpc_id = module.docuflow-vpc.vpc_id
    # lambda_security_group_id = module.docuflow-vpc.lambda_security_group_id
    # lambda_subnet_ids = module.docuflow-vpc.private_subnet_ids

    docuflow_sfn_arn = module.docuflow-sfn.docuflow_sfn_arn

    docuflow_user_pool_id = module.cognito.docuflow_user_pool_id

    depends_on = [ 
        module.docuflow-sfn, 
        # module.docuflow-vpc, 
        module.s3-buckets 
    ]
}

module "docuflow-api-gw" {
    source = "./api"
    web_client_id = module.cognito.cognito_user_pool_client_id
    user_pool_endpoint = module.cognito.cognito_user_pool_endpoint
    lambda-get-upload-document-url-invoke-arn = module.lambda-functions.lambda-get-upload-document-url-invoke-arn
    lambda-get-view-document-url-invoke-arn = module.lambda-functions.lambda-get-view-document-url-invoke-arn
    lambda-submit-document-invoke-arn = module.lambda-functions.lambda-submit-document-invoke-arn
    lambda-approval-documents-invoke-arn = module.lambda-functions.lambda-approval-documents-invoke-lambda
    lambda-submitted-documents-invoke-arn = module.lambda-functions.lambda-submitted-documents-invoke-arn
    lambda-approve-document-invoke-arn = module.lambda-functions.lambda-approve-document-invoke-arn
}

module "database" {
    source = "./database"
}   

module "monitoring" {
    source = "./monitoring"
}