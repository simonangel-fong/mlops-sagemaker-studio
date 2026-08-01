## Development

```sh
terraform -chdir=infra init -backend-config=backend.hcl -reconfigure
terraform -chdir=infra fmt && terraform -chdir=infra validate

terraform -chdir=infra apply -auto-approve

terraform -chdir=infra destroy -auto-approve

```

## Runbook

```sh
# debug commands
# apps in the domain (the things blocking space deletion)
aws sagemaker list-apps --domain-id-equals d-tjopcmpvemcl --region ca-central-1 --output table

# spaces in the domain
aws sagemaker list-spaces --domain-id-equals d-tjopcmpvemcl --region ca-central-1 --output table


aws sagemaker delete-app \
  --domain-id d-tjopcmpvemcl \
  --space-name admin-alice-jupyterlab \
  --app-type JupyterLab \
  --app-name default \
  --region ca-central-1

```