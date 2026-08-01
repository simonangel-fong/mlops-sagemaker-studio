# sagemaker-studio.tf

# ##############################
# Sagemaker Studio Domain
# ##############################
resource "aws_sagemaker_domain" "this" {
  domain_name = "${local.prefix_name}-domain"
  auth_mode   = "IAM"

  # Network
  vpc_id                  = var.vpc_id
  subnet_ids              = var.public_subnet_ids
  app_network_access_type = "PublicInternetOnly"

  # security
  kms_key_id = aws_kms_key.this.arn

  # apps
  default_user_settings {
    execution_role = aws_iam_role.alice.arn

    # # notebook
    # jupyter_lab_app_settings {
    #   default_resource_spec {
    #     instance_type = "ml.t3.medium"
    #   }

    #   lifecycle_config_arns = [aws_sagemaker_studio_lifecycle_config.clone_repo.arn]
    # }
  }

  # drop the EFS volume on destroy
  retention_policy {
    home_efs_file_system = "Delete"
  }
}

# ##############################
# Lifecycle config: JupyterLab 
# ##############################
resource "aws_sagemaker_studio_lifecycle_config" "clone_repo" {
  studio_lifecycle_config_name     = "${local.prefix_name}-clone-repo"
  studio_lifecycle_config_app_type = "JupyterLab"

  studio_lifecycle_config_content = base64encode(
    templatefile("${path.module}/scripts/clone-repo.sh", {
      repo_url = var.git_repository_url
    })
  )
}
