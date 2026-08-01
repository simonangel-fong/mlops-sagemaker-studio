# sagemaker-studio-model.tf

# ##############################
# Model package group
# ##############################
resource "aws_sagemaker_model_package_group" "bike" {
  model_package_group_name        = "${local.prefix_name}-bike-sharing-rf"
  model_package_group_description = "Bike sharing demand models."
}
