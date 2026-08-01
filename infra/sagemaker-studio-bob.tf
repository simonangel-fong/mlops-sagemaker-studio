# sagemaker-studio-bob.tf

# ##############################
# IAM Role: Bob
# ##############################
resource "aws_iam_role" "bob" {
  name = "${local.prefix_name}-role-bob"

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

# ##############################
# Studio access
# ##############################
# Enumerated rather than AmazonSageMakerFullAccess: alice has the managed
# policy, bob gets only what opening the app and running a space needs.
data "aws_iam_policy_document" "studio_access" {
  statement {
    sid    = "StudioAppAccess"
    effect = "Allow"

    actions = [
      "sagemaker:CreatePresignedDomainUrl",
      "sagemaker:DescribeDomain",
      "sagemaker:ListDomains",
      "sagemaker:DescribeUserProfile",
      "sagemaker:ListUserProfiles",
      "sagemaker:DescribeSpace",
      "sagemaker:ListSpaces",
      "sagemaker:CreateApp",
      "sagemaker:DescribeApp",
      "sagemaker:DeleteApp",
      "sagemaker:ListApps",
      "sagemaker:DescribeStudioLifecycleConfig",
      "sagemaker:ListStudioLifecycleConfigs",
    ]

    resources = ["*"]
  }

  # The app runs as this role, so it has to be able to hand it to itself.
  statement {
    sid       = "PassRoleToApp"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.bob.arn]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "studio_access" {
  name        = "${local.prefix_name}-studio-access"
  description = "Open Studio and run a JupyterLab app."
  policy      = data.aws_iam_policy_document.studio_access.json
}

resource "aws_iam_role_policy_attachment" "bob_studio_access" {
  role       = aws_iam_role.bob.name
  policy_arn = aws_iam_policy.studio_access.arn
}

# ##############################
# Data access
# ##############################
data "aws_iam_policy_document" "bob_data_access" {
  statement {
    sid       = "S3ListReadablePrefixes"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.data.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "${local.bob_prefix}*",
        "raw/*",
        "featured/*",
        "model/*",
        "${local.mlflow_prefix}*",
      ]
    }
  }

  # head_bucket sends ListBucket with no s3:prefix key at all, so the
  # StringLike above cannot match and the call 403s. Null:true matches
  # exactly the keyless case: bob can confirm the bucket exists, but
  # enumerating it still has to go through the prefixes above.
  statement {
    sid       = "S3HeadBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.data.arn]

    condition {
      test     = "Null"
      variable = "s3:prefix"
      values   = ["true"]
    }
  }

  statement {
    sid       = "S3GetBucketLocation"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    resources = [aws_s3_bucket.data.arn]
  }

  statement {
    sid     = "S3ReadSharedData"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.data.arn}/raw/*",
      "${aws_s3_bucket.data.arn}/featured/*",
      "${aws_s3_bucket.data.arn}/model/*",
    ]
  }

  # Read and write his own prefix.
  statement {
    sid    = "S3ReadWriteOwnPrefix"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = ["${aws_s3_bucket.data.arn}/${local.bob_prefix}*"]
  }

  statement {
    sid       = "S3ReadMlflowArtifacts"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.data.arn}/${local.mlflow_prefix}*"]
  }

  statement {
    sid    = "DenyWritesToAliceOutputs"
    effect = "Deny"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      "${aws_s3_bucket.data.arn}/featured/*",
      "${aws_s3_bucket.data.arn}/model/*",
      "${aws_s3_bucket.data.arn}/${local.mlflow_prefix}*",
    ]
  }

  statement {
    sid    = "KmsUse"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [aws_kms_key.this.arn]
  }

  statement {
    sid    = "SageMakerJobs"
    effect = "Allow"

    actions = [
      "sagemaker:CreateTrainingJob",
      "sagemaker:DescribeTrainingJob",
      "sagemaker:StopTrainingJob",
      "sagemaker:ListTrainingJobs",
      "sagemaker:CreateProcessingJob",
      "sagemaker:DescribeProcessingJob",
      "sagemaker:StopProcessingJob",
      "sagemaker:ListProcessingJobs",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Pipelines"
    effect = "Allow"

    actions = [
      "sagemaker:CreatePipeline",
      "sagemaker:UpdatePipeline",
      "sagemaker:DescribePipeline",
      "sagemaker:DescribePipelineDefinitionForExecution",
      "sagemaker:ListPipelines",
      "sagemaker:StartPipelineExecution",
      "sagemaker:StopPipelineExecution",
      "sagemaker:DescribePipelineExecution",
      "sagemaker:ListPipelineExecutions",
      "sagemaker:ListPipelineExecutionSteps",
      "sagemaker:ListPipelineParametersForExecution",
      "sagemaker:AddTags",
      "sagemaker:ListTags",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ModelRegistryReadAndRegister"
    effect = "Allow"

    actions = [
      "sagemaker:CreateModel",
      "sagemaker:DescribeModel",
      "sagemaker:CreateModelPackage",
      "sagemaker:DescribeModelPackage",
      "sagemaker:ListModelPackages",
      "sagemaker:DescribeModelPackageGroup",
      "sagemaker:ListModelPackageGroups",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "DenyApproval"
    effect = "Deny"

    actions = [
      "sagemaker:UpdateModelPackage",
      "sagemaker:DeleteModelPackage",
      "sagemaker:DeleteModelPackageGroup",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "DenyDeployment"
    effect = "Deny"

    actions = [
      "sagemaker:CreateEndpoint",
      "sagemaker:UpdateEndpoint",
      "sagemaker:DeleteEndpoint",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:DeleteEndpointConfig",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "StudioResourceSearch"
    effect = "Allow"

    actions = [
      "sagemaker:Search",
      "sagemaker:GetSearchSuggestions",
    ]

    resources = ["*"]
  }

  statement {
    sid       = "CloudWatchLogsDiscovery"
    effect    = "Allow"
    actions   = ["logs:DescribeLogGroups"]
    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchLogsRead"
    effect = "Allow"

    actions = [
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
      "logs:StartQuery",
      "logs:GetQueryResults",
      "logs:StopQuery",
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/sagemaker/*",
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/sagemaker/*:log-stream:*",
    ]
  }

  statement {
    sid    = "EcrPullJobImages"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = ["*"]
  }

  # Log runs to the MLflow app. Without this the notebook fails on the
  # first tracking call -- the sagemaker-mlflow plugin signs against
  # sagemaker-mlflow:*, not the sagemaker:* actions above.
  statement {
    sid    = "MlflowTracking"
    effect = "Allow"

    actions = [
      "sagemaker-mlflow:AccessUI",
      "sagemaker-mlflow:CreateExperiment",
      "sagemaker-mlflow:SearchExperiments",
      "sagemaker-mlflow:GetExperiment",
      "sagemaker-mlflow:CreateRun",
      "sagemaker-mlflow:UpdateRun",
      "sagemaker-mlflow:DeleteRun",
      "sagemaker-mlflow:SearchRuns",
      "sagemaker-mlflow:GetRun",
      "sagemaker-mlflow:LogMetric",
      "sagemaker-mlflow:LogParam",
      "sagemaker-mlflow:LogBatch",
      "sagemaker-mlflow:SetTag",
      "sagemaker-mlflow:LogModel",
      "sagemaker-mlflow:GetRegisteredModel",
      "sagemaker-mlflow:SearchRegisteredModels",
      "sagemaker-mlflow:CreateRegisteredModel",
      "sagemaker-mlflow:CreateModelVersion",
      "sagemaker-mlflow:GetModelVersion",
      "sagemaker-mlflow:SearchModelVersions",
    ]

    resources = [aws_sagemaker_mlflow_app.this.arn]
  }

  # Reaching the app also needs the presigned-URL call and a describe.
  statement {
    sid    = "MlflowApp"
    effect = "Allow"

    actions = [
      "sagemaker:CreatePresignedMlflowAppUrl",
      "sagemaker:DescribeMlflowApp",
      "sagemaker:ListMlflowApps",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "bob_data_access" {
  name        = "${local.prefix_name}-bob-data-access"
  description = "Read shared data, write only to bob's own prefix."
  policy      = data.aws_iam_policy_document.bob_data_access.json
}

resource "aws_iam_role_policy_attachment" "bob_data_access" {
  role       = aws_iam_role.bob.name
  policy_arn = aws_iam_policy.bob_data_access.arn
}


# ##############################
# Profile and space
# ##############################
resource "aws_sagemaker_user_profile" "bob" {
  domain_id         = aws_sagemaker_domain.this.id
  user_profile_name = "bob"

  user_settings {
    execution_role = aws_iam_role.bob.arn
  }
}

resource "aws_sagemaker_space" "bob" {
  domain_id  = aws_sagemaker_domain.this.id
  space_name = "bob-jupyterlab"

  space_sharing_settings {
    sharing_type = "Private"
  }

  ownership_settings {
    owner_user_profile_name = aws_sagemaker_user_profile.bob.user_profile_name
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
