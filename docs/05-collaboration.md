# Amazon SageMaker Studio Demo - Collaboration

[Back](../README.md)

- [Amazon SageMaker Studio Demo - Collaboration](#amazon-sagemaker-studio-demo---collaboration)
  - [Collaboration](#collaboration)

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
