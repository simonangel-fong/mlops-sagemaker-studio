# # iam-mlflow.tf

# data "aws_iam_policy_document" "mlflow_access" {
#   statement {
#     sid    = "MlflowAppControlPlane"
#     effect = "Allow"

#     actions = ["sagemaker:*MlflowApp*"]

#     resources = ["*"]
#   }

#   statement {
#     sid     = "MlflowDataPlane"
#     effect  = "Allow"
#     actions = ["sagemaker-mlflow:*"]

#     resources = [aws_sagemaker_mlflow_app.this.arn]
#   }
# }

# resource "aws_iam_policy" "mlflow_access" {
#   name        = "${local.prefix_name}-mlflow-access"
#   description = "Log and read experiments on the MLflow app."
#   policy      = data.aws_iam_policy_document.mlflow_access.json
# }

# resource "aws_iam_role_policy_attachment" "alice_mlflow_access" {
#   role       = aws_iam_role.alice.name
#   policy_arn = aws_iam_policy.mlflow_access.arn
# }
