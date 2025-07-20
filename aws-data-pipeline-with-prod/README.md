## 💪 AWS Data Platform Deployment – Terraform Project

This project provisions a complete **modular and reusable AWS data platform** using Terraform, with support for **staging** and **production** environments.

---

### 📁 Folder Structure

```bash
aws-data-pipeline/
├── modules/
│   └── core/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── glue-job.py
│       ├── step_function_definition.asl.json
│       ├── databricks_notebook.dbc
├── envs/
│   ├── staging/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   └── production/
│       ├── main.tf
│       └── terraform.tfvars
├── .github/
│   └── workflows/
│       └── deploy.yml
├── README.md
```

---

### 🚀 Components Deployed

| Component                      | Included? | Notes                             |
| ------------------------------ | --------- | --------------------------------- |
| VPC + Subnets                  | ✅         | For isolation and Glue/RDS        |
| S3 Storage Bucket              | ✅         | For Glue job input/output         |
| RDS PostgreSQL (or MySQL)      | ✅         | Sample database provisioned       |
| Glue Catalog + Table           | ✅         | Crawl S3 and register schema      |
| Glue Job (Python)              | ✅         | Reads from S3 and writes to RDS   |
| Glue Connection (JDBC to RDS)  | ✅         | Used in the ETL job               |
| Databricks Workspace           | ✅         | On AWS, integrated with GitHub    |
| Databricks Notebook            | ✅         | Sample notebook included (`.dbc`) |
| Step Functions Orchestration   | ✅         | Alternative to ADF pipelines      |
| EventBridge Trigger (Schedule) | ✅         | Cron-based pipeline trigger       |
| Lambda Function (Optional)     | ✅         | For failover/recovery             |
| GitHub Actions CI/CD           | ✅         | Deploys Terraform infra           |
| Athena (Optional)              | ✅         | Query Glue Catalog tables         |
| Secrets Manager (Optional)     | ✅         | Store DB credentials securely     |

---

### ✅ Prerequisites

* AWS CLI configured with admin access
* Terraform CLI (v1.3+ recommended)
* GitHub account + repo (for CI/CD)
* GitHub Personal Access Token (if pushing code to Databricks from GitHub)

---

### 🔧 Setup Instructions

1. **Clone the repo and navigate to environment**

   ```bash
   git clone https://github.com/your-org/aws-data-pipeline.git
   cd aws-data-pipeline/envs/staging
   ```

2. **Initialize Terraform**

   ```bash
   terraform init
   ```

3. **Review the plan**

   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```

4. **Apply infrastructure**

   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

5. **(Optional) Trigger Step Function manually**

   ```bash
   aws stepfunctions start-execution \
     --state-machine-arn arn:aws:states:region:account-id:stateMachine:MyStateMachine \
     --name "exec-$(date +%s)" \
     --input '{}'
   ```

---

### 📡 CI/CD via GitHub Actions

Located in `.github/workflows/deploy.yml`:

* Automatically applies changes when you `git push` to `main`.
* Requires GitHub secrets:

  * `AWS_ACCESS_KEY_ID`
  * `AWS_SECRET_ACCESS_KEY`

---

### 📘 Databricks GitHub Integration

* Sample notebook (`databricks_notebook.dbc`) is included.
* You can import it via Databricks UI or push via Databricks CLI:

  ```bash
  databricks workspace import databricks_notebook.dbc /Workspace/Notebooks/etl_pipeline
  ```

---

### 🗕️ Scheduling

* Uses **EventBridge Rules** to trigger Step Functions (like ADF triggers).
* Cron schedule can be customized in `main.tf`.

---

### 📊 Sample Queries with Athena

Once data is cataloged by Glue:

```sql
SELECT * FROM glue_catalog_db.sample_table LIMIT 10;
```

---

### 🔐 Secrets Management

* Store DB passwords or JDBC URLs in AWS Secrets Manager.
* Access from Glue Jobs or Lambda securely using IAM roles.

---

### 📦 Deployment Targets

Supports multi-env deployment:

```bash
cd envs/staging     # for test/staging
cd envs/production  # for production

terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```
📊 AWS Data Pipeline – Multi-Environment Architecture

                               ┌──────────────────────────────┐
                               │        GitHub Repo           │
                               │  └── .github/workflows       │
                               └────────────┬─────────────────┘
                                            │
                         ┌──────────────────▼─────────────────┐
                         │        GitHub Actions CI/CD        │
                         └──────┬────────────────────┬────────┘
                                │                    │
                  ┌────────────▼──────────┐ ┌────────▼─────────────┐
                  │   envs/staging/       │ │   envs/production/   │
                  │ └── terraform.tfvars  │ │ └── terraform.tfvars │
                  └────────────┬──────────┘ └────────┬─────────────┘
                               │                      │
                      ┌────────▼────────┐     ┌───────▼────────┐
                      │   AWS VPC       │     │    AWS VPC     │
                      │ └── Subnets     │     │ └── Subnets    │
                      └────────┬────────┘     └───────┬────────┘
                               │                      │
           ┌───────────────────▼──────────────────────▼────────────────────┐
           │                Shared Terraform Module: modules/core/         │
           │ ┌────────────────────────────────────────────────────────────┐ │
           │ │  - S3 Bucket (storage)                                     │ │
           │ │  - RDS (PostgreSQL)                                        │ │
           │ │  - Secrets Manager (passwords)                             │ │
           │ │  - Glue Data Catalog + Jobs + Connection to RDS (JDBC)     │ │
           │ │  - PrivateLink/Endpoints (to RDS, S3 if needed)            │ │
           │ │  - Step Functions (Pipeline orchestration)                 │ │
           │ │  - EventBridge (for scheduling)                            │ │
           │ │  - Lambda (failover, notification, triggers)               │ │
           │ │  - Optional: Databricks (via AWS integration & token)      │ │
           │ └────────────────────────────────────────────────────────────┘ │
           └────────────────────────────────────────────────────────────────┘

✅ Summary of AWS Environment Isolation
| Component             | Staging                     | Production               |
| --------------------- | --------------------------- | ------------------------ |
| `terraform.tfvars`    | `envs/staging/`             | `envs/production/`       |
| VPC + Subnet          | Isolated                    | Isolated                 |
| S3 Bucket             | e.g., `staging-data-bucket` | e.g., `prod-data-bucket` |
| RDS                   | e.g., `staging-db`          | e.g., `prod-db`          |
| Secrets Manager       | Separate secrets per env    | Separate secrets per env |
| Glue Catalog          | Unique database/schema      | Unique database/schema   |
| Step Functions        | Separate workflows          | Separate workflows       |
| Databricks (Optional) | Uses separate workspace     | Uses separate workspace  |
