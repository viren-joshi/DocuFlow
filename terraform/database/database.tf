resource "aws_dynamodb_table" "docuflow_documents" {
    name = "DocuFlowDocuments"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "documentId"
    range_key = "approverId"

    attribute {
      name = "documentId"
      type = "S"
    }

    attribute {
      name = "approverId"
      type = "S"
    }

    attribute {
      name = "submittedBy"
      type = "S"
    }

    tags = {
        Project = "DocuFlow"
    }

    global_secondary_index {
      name = "Submitted-Index"
      hash_key = "submittedBy"
      projection_type = "ALL"
    }

    global_secondary_index {
      name = "Approver-Index"
      hash_key = "approverId"
      projection_type = "ALL"
    }

}
