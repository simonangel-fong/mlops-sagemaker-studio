# iam-pipeline.tf

# ##############################
# Model package group
# ##############################
resource "aws_sagemaker_model_package_group" "bike" {
  model_package_group_name        = "${local.prefix_name}-bike-sharing-rf"
  model_package_group_description = "Bike sharing demand models."
}


# data "aws_iam_policy_document" "pipeline_access" {
#   statement {
#     sid    = "CloudWatchLogsSearch"
#     effect = "Allow"

#     actions = [
#       "logs:FilterLogEvents",
#       "logs:StartQuery",
#       "logs:GetQueryResults",
#       "logs:StopQuery",
#     ]

#     resources = [
#       "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/sagemaker/*",
#       "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/sagemaker/*:log-stream:*",
#     ]
#   }
# }

# resource "aws_iam_policy" "pipeline_access" {
#   name        = "${local.prefix_name}-pipeline-access"
#   description = "Read job logs back. The SageMaker grants come from AmazonSageMakerFullAccess."
#   policy      = data.aws_iam_policy_document.pipeline_access.json
# }

# resource "aws_iam_role_policy_attachment" "alice_pipeline_access" {
#   role       = aws_iam_role.alice.name
#   policy_arn = aws_iam_policy.pipeline_access.arn
# }
