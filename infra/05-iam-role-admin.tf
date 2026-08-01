# iam-role-admintf

# ##############################
# IAM Role: Alice
# ##############################
resource "aws_iam_role" "alice" {
  name = "${local.prefix_name}-role-alice"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      },
    ]
  })
}

# full sagemaker 
resource "aws_iam_role_policy_attachment" "alice_sagemaker_full" {
  role       = aws_iam_role.alice.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}
