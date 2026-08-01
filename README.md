# Amazon SageMaker Studio Demo

A side project that explores the key features of Amazon SageMaker Studio.

- [Amazon SageMaker Studio Demo](#amazon-sagemaker-studio-demo)
  - [Sagamaker Studio](#sagamaker-studio)
  - [Feature: JupyterLab](#feature-jupyterlab)
  - [Feature: MLFlow](#feature-mlflow)
  - [Feature: Pipeline](#feature-pipeline)
  - [Feature: Collaboration](#feature-collaboration)
  - [Documentation](#documentation)

---

## Sagamaker Studio

- `Amazon SageMaker Studio`
  - A web-based, unified `integrated development environment (IDE)` designed for complete, end-to-end machine learning and data workflows.
  - Provides access to tools such as `JupyterLab`, `Code Editor (VS Code Open Source)`, and `RStudio` to build, train, tune, and deploy AI models.

![studio](./docs/img/studio01.png)

---

## Feature: JupyterLab

- `JupyterLab feature`
  - A managed Jupyter notebook instance within SageMaker Studio.

- JupyterLab UI
  ![notebook01](./docs/img/notebook01.png)

- Notebook UI
  ![notebook02](./docs/img/notebook02.png)

- Training with the classic bike sharing dataset
  ![notebook03](./docs/img/notebook03.png)

  ![notebook04](./docs/img/notebook04.png)

---

## Feature: MLFlow

- `MLflow feature`
  - Fully managed **`MLflow` tracking servers** to track experiments, log metrics, and handle model governance directly from the workspace.

- MLflow UI
  ![mlflow01](./docs/img/mlflow01.png)
  ![mlflow02](./docs/img/mlflow02.png)

- Experiment Tracking

  ![mlflow05](./docs/img/mlflow05.png)

  ![mlflow06](./docs/img/mlflow06.png)

  ![mlflow07](./docs/img/mlflow07.png)

---

## Feature: Pipeline

- `Pipeline feature`
  - Create a pipeline with the SageMaker Python SDK.

- Pipeline UI

  ![pipeline01](./docs/img/pipeline01.png)

  ![pipeline02](./docs/img/pipeline02.png)

- Execution
  ![pipeline03](./docs/img/pipeline03.png)

- Registered Model
  ![pipeline04](./docs/img/pipeline04.png)

---

## Feature: Collaboration

- Onboard a data scientist named "Bob".

- Log in as "Bob"
  ![bob01](./docs/img/bob01.png)

- Train and save a model as "Bob"
  ![bob02](./docs/img/bob02.png)

---

## Documentation

- [IaC with Terraform](./docs/01-infra.md)
- [Jupyter Notebook](./docs/02-notebook.md)
- [MLflow](./docs/03-mlflow.md)
- [Pipeline](./docs/04-pipeline.md)
- [Collaboration](./docs/05-collaboration.md)
