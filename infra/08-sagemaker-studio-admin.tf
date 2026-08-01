# sagemaker-studio-admin.tf

# ##############################
# Space: jupyterlab
# ##############################
resource "aws_sagemaker_space" "admin_alice" {
  space_name = "admin-alice-jupyterlab"
  domain_id  = aws_sagemaker_domain.this.id

  space_sharing_settings {
    sharing_type = "Private"
  }

  ownership_settings {
    owner_user_profile_name = aws_sagemaker_user_profile.admin_alice.user_profile_name
  }

  space_settings {
    app_type = "JupyterLab"

    jupyter_lab_app_settings {
      default_resource_spec {
        instance_type        = var.notebook_instance_type
        lifecycle_config_arn = aws_sagemaker_studio_lifecycle_config.clone_repo.arn
      }

      code_repository {
        repository_url = var.git_repository_url
      }
    }

    space_storage_settings {
      ebs_storage_settings {
        ebs_volume_size_in_gb = var.notebook_volume_size
      }
    }
  }
}
