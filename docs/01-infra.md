# Amazon SageMaker Studio Demo - Infrastructure

[Back](../README.md)

- [Amazon SageMaker Studio Demo - Infrastructure](#amazon-sagemaker-studio-demo---infrastructure)
  - [IaC: Terraform](#iac-terraform)
  - [Runbook](#runbook)

---

## IaC: Terraform

```sh
terraform -chdir=infra init -backend-config=backend.hcl -reconfigure
terraform -chdir=infra fmt && terraform -chdir=infra validate

terraform -chdir=infra apply -auto-approve
terraform -chdir=infra refresh

terraform -chdir=infra destroy -auto-approve
```

---

## Runbook

- debug commands

```sh
# apps in the domain (the things blocking space deletion)
aws sagemaker list-apps --domain-id-equals d-tjopcmpvemcl --region ca-central-1 --output table

# spaces in the domain
aws sagemaker list-spaces --domain-id-equals d-tjopcmpvemcl --region ca-central-1 --output table

# remove apps
aws sagemaker delete-app \
  --domain-id d-tjopcmpvemcl \
  --space-name admin-alice-jupyterlab \
  --app-type JupyterLab \
  --app-name default \
  --region ca-central-1
```
