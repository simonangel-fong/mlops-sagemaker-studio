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

# # ##############################
# # User profile: alice (admin)
# # ##############################
# resource "aws_sagemaker_user_profile" "alice" {
#   domain_id         = aws_sagemaker_domain.this.id
#   user_profile_name = "alice"

#   user_settings {
#     execution_role = aws_iam_role.alice.arn
#   }
# }

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

# # ##############################
# # Space
# # ##############################
# resource "aws_sagemaker_space" "alice" {
#   domain_id  = aws_sagemaker_domain.this.id
#   space_name = "alice-jupyterlab"

#   space_sharing_settings {
#     sharing_type = "Private"
#   }

#   ownership_settings {
#     owner_user_profile_name = aws_sagemaker_user_profile.alice.user_profile_name
#   }

#   space_settings {
#     app_type = "JupyterLab"

#     jupyter_lab_app_settings {
#       default_resource_spec {
#         instance_type        = var.space_instance_type
#         lifecycle_config_arn = aws_sagemaker_studio_lifecycle_config.clone_repo.arn
#       }

#       # The LCC does the cloning; this just lists the repo in the git menu.
#       code_repository {
#         repository_url = var.git_repository_url
#       }
#     }

#     space_storage_settings {
#       ebs_storage_settings {
#         ebs_volume_size_in_gb = var.space_volume_size
#       }
#     }
#   }
# }
