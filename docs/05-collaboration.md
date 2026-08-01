# Amazon SageMaker Studio Demo - Collaboration

[Back](../README.md)

- [Amazon SageMaker Studio Demo - Collaboration](#amazon-sagemaker-studio-demo---collaboration)
  - [Permission Comparison](#permission-comparison)
  - [Collaboration](#collaboration)

---

## Permission Comparison

Alice (admin) holds the AWS managed policies `AmazonSageMakerFullAccess` and
`AmazonS3FullAccess`. Bob holds two customer-managed policies that enumerate
only what a data scientist needs, plus explicit `Deny` statements on the
promotion path.

| Area                               | Alice (admin)                                              | Bob (data scientist)                                                                                                                                    |
| ---------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| IAM role                           | `…-role-alice`                                             | `…-role-bob`                                                                                                                                            |
| Policy source                      | Managed: `AmazonSageMakerFullAccess`, `AmazonS3FullAccess` | Custom: `…-studio-access`, `…-bob-data-access`                                                                                                          |
| Open Studio / run a JupyterLab app | Yes                                                        | Yes (`CreatePresignedDomainUrl`, `CreateApp`/`DeleteApp`, describe + list on domain, profile, space, app, lifecycle config)                             |
| PassRole                           | Any role                                                   | Only own role, and only to `sagemaker.amazonaws.com`                                                                                                    |
| S3 — bucket listing                | All buckets                                                | `ListBucket` on the data bucket only, limited to the prefixes `users/bob/`, `raw/`, `featured/`, `model/`, `mlflow-app/` (plus a keyless `head_bucket`) |
| S3 — `raw/`                        | Read + write                                               | **Read only**                                                                                                                                           |
| S3 — `featured/`                   | Read + write                                               | **Read only** (explicit `Deny` on put/delete/put-acl)                                                                                                   |
| S3 — `model/`                      | Read + write                                               | **Read only** (explicit `Deny` on put/delete/put-acl)                                                                                                   |
| S3 — `mlflow-app/`                 | Read + write                                               | **Read only** (explicit `Deny` on put/delete/put-acl)                                                                                                   |
| S3 — `users/bob/`                  | Read + write                                               | Read + write + delete                                                                                                                                   |
| KMS                                | Full                                                       | Encrypt / Decrypt / ReEncrypt / GenerateDataKey / DescribeKey on the project key only                                                                   |
| Training & processing jobs         | Full                                                       | Create / Describe / Stop / List                                                                                                                         |
| Pipelines                          | Full                                                       | Create / Update / Describe / List, start & stop executions, read execution steps, tags                                                                  |
| Model registry                     | Full                                                       | Create model, create model package/version, describe + list                                                                                             |
| Approve or delete a model package  | Yes                                                        | **Denied** (`UpdateModelPackage`, `DeleteModelPackage`, `DeleteModelPackageGroup`)                                                                      |
| Endpoints (deploy to production)   | Yes                                                        | **Denied** (create/update/delete endpoint and endpoint config)                                                                                          |
| MLflow tracking                    | Full                                                       | Create/search experiments and runs, log metrics, params, batches, tags, models; register models and versions — scoped to the project MLflow app ARN     |
| MLflow UI access                   | Yes                                                        | Yes (`AccessUI`, `CreatePresignedMlflowAppUrl`, describe + list apps)                                                                                   |
| CloudWatch Logs                    | Full                                                       | Read only, scoped to `/aws/sagemaker/*` log groups (plus account-wide `DescribeLogGroups`)                                                              |
| ECR                                | Full                                                       | Pull only (`GetAuthorizationToken`, `BatchGetImage`, `BatchCheckLayerAvailability`, `GetDownloadUrlForLayer`)                                           |
| Resource search in Studio          | Yes                                                        | Yes (`Search`, `GetSearchSuggestions`)                                                                                                                  |

The separation of duties: Bob can go all the way from raw data to a registered
model version, but he cannot approve that version, delete it, or put anything
behind an endpoint. Alice does the promotion.

---

## Collaboration

- Onboard a data scientist named "Bob".

- Login as "Bob"
  ![bob01](./img/bob01.png)

- Train model as "Bob"
  ![bob02](./img/bob02.png)

```sh
# confirm
aws s3 ls "s3://mlops-sagemaker-studio-dev-data-3vi8kw/users/bob/model/"
# 2026-08-01 18:45:16        121 features.joblib
# 2026-08-01 18:45:15   12546337 model.joblib
```
