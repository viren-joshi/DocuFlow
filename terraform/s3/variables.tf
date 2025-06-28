variable "frontend_bucket_name" {
  type = string
  description = "S3 bucket name for DocuFlow frontend"
  default = "docuflow-frontend-bucket"
}

variable "docuflow_init_bucket" {
  type = string
  description = "S3 bucket name for DocuFlow initialization files"
  default = "docuflow-init-bucket"
}

variable "docuflow_document_bucket" {
  type = string
  description = "S3 bucket name for DocuFlow documents"
  default = "docuflow-document-bucket"
}