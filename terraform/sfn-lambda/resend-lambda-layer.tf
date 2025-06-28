resource "aws_lambda_layer_version" "resend_layer" {
  layer_name  = "resend-layer"
  description = "Layer containing resend module"
  compatible_runtimes = ["python3.11"]

  s3_bucket = "docuflow-init-bucket"
  s3_key    = "lambda-layers/layer.zip"
}