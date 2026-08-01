# outputs.tf

# ##############################
# Bucket
# ##############################
output "data_bucket" {
  description = "S3 bucket for raw data, features and model artifacts."
  value       = aws_s3_bucket.data.id
}

# ##############################
# Studio
# ##############################

output "admin_alice_role_arn" {
  value = aws_iam_role.alice.arn
}

output "studio_domain_id" {
  value = aws_sagemaker_domain.this.id
}

output "studio_login_command" {
  description = "CLI command that returns a presigned Studio URL for alice."
  value       = "aws sagemaker create-presigned-domain-url --domain-id ${aws_sagemaker_domain.this.id} --user-profile-name ${aws_sagemaker_user_profile.admin_alice.user_profile_name} --region ${var.aws_region} --query AuthorizedUrl --output text"
}

# ##############################
# Notebook
# ##############################
output "notebook_url" {
  value = aws_sagemaker_space.admin_alice.url
}

# ##############################
# MLflow
# ##############################
output "mlflow_app_arn" {
  description = "Tracking URI for mlflow.set_tracking_uri()."
  value       = aws_sagemaker_mlflow_app.this.arn
}

output "mlflow_ui_command" {
  description = "CLI command that returns a presigned MLflow UI URL."
  value       = "aws sagemaker create-presigned-mlflow-app-url --arn ${aws_sagemaker_mlflow_app.this.arn} --region ${var.aws_region} --query AuthorizedUrl --output text"
}

output "model_package_group" {
  description = "Model registry group the pipeline registers versions into."
  value       = aws_sagemaker_model_package_group.bike.model_package_group_name
}

# ##############################
# Phase 9 -- bob
# ##############################
output "bob_role_arn" {
  description = "Execution role for the bob profile. Scoped to his own prefix."
  value       = aws_iam_role.bob.arn
}

output "bob_login_command" {
  description = "CLI command that returns a presigned Studio URL for bob."
  value       = "aws sagemaker create-presigned-domain-url --domain-id ${aws_sagemaker_domain.this.id} --user-profile-name ${aws_sagemaker_user_profile.bob.user_profile_name} --region ${var.aws_region} --query AuthorizedUrl --output text"
}

output "bob_prefix" {
  description = "The only prefix bob can write to."
  value       = "s3://${aws_s3_bucket.data.id}/${local.bob_prefix}"
}
