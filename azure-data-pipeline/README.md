🚀 Azure Data Platform Deployment – Terraform Project

This project provisions a fully modular, reusable Azure data platform using Terraform with support for staging and production environments.

## 🚀 Azure Data Platform Deployment – Terraform Project

This project provisions a fully modular, reusable **Azure data platform** using Terraform with support for **staging** and **production** environments.

---

### 📁 Folder Structure

```bash
azure-data-pipeline/
├── modules/
│   └── core/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── pipeline.json
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

### ✅ Components Included

| Component                      | Status | Notes                            |
| ------------------------------ | ------ | -------------------------------- |
| Azure Resource Group           | ✅      | Base resource group              |
| Storage Account (LRS Tier)     | ✅      | Secure with HTTPS only           |
| Azure SQL Server + Database    | ✅      | Admin user, basic SKU            |
| Key Vault + Secrets            | ✅      | Integrated with ADF MSI          |
| Azure Data Factory (ADF)       | ✅      | GitHub publishing configured     |
| Databricks Workspace           | ✅      | Standard SKU, managed RG         |
| ADF Linked Services (SQL, DBX) | ✅      | Includes datasets for both       |
| ADF Pipeline (JSON)            | ✅      | Sample pipeline + trigger        |
| Integration Runtime (Auto)     | ✅      | AutoResolve used                 |
| Virtual Network + Subnet       | ✅      | For private endpoints            |
| Private Endpoints (ADF, SQL)   | ✅      | With DNS zone integration        |
| Private DNS Zones (ADF)        | ✅      | Linked to VNet                   |
| GitHub Actions CI/CD           | ✅      | Auto-deploys from push to `main` |

---

### ⚙ Prerequisites

* Terraform CLI (v1.3+)
* Azure CLI authenticated (`az login`)
* Azure subscription with necessary roles
* GitHub repository + PAT (for ADF Git publishing)

---

### 🔧 Setup Instructions

1. **Clone the repo and enter an environment:**

```bash
git clone https://github.com/your-org/azure-data-pipeline.git
cd azure-data-pipeline/envs/staging
```

2. **Initialize Terraform:**

```bash
terraform init
```

3. **Plan infrastructure changes:**

```bash
terraform plan -var-file="terraform.tfvars"
```

4. **Apply infrastructure:**

```bash
terraform apply -var-file="terraform.tfvars"
```

---

### ⚡ CI/CD via GitHub Actions

Stored in `.github/workflows/deploy.yml`

* Deploys infra on each push to `main`
* Requires secrets:

  * `ARM_CLIENT_ID`
  * `ARM_CLIENT_SECRET`
  * `ARM_SUBSCRIPTION_ID`
  * `ARM_TENANT_ID`

---

### 📘 GitHub Integration (ADF)

* Configured in `azurerm_data_factory` via `repo_configuration`
* Commits to `main` auto-trigger pipeline updates

---

### 📊 Sample ADF Pipeline

The sample pipeline copies data from Azure SQL to Databricks (Parquet on DBFS):

* Source: SQL dataset (`my_table`)
* Sink: Databricks mount (`/mnt/data/sample.parquet`)
* Trigger: Daily at midnight (can be updated)

Defined in `pipeline.json`.

---

### 🔐 Secrets Management

* Secrets (SQL password, tokens) are stored in **Key Vault**
* ADF MSI granted **Get/List** access via `azurerm_key_vault_access_policy`

---

### 🧠 Databricks Integration

* `azurerm_databricks_workspace` provisioned
* Linked to ADF via `azurerm_data_factory_linked_service_azure_databricks`
* Access token from `terraform.tfvars` used for auth

---

### 📡 Private Network + DNS

* VNet + subnet for endpoint isolation
* ADF private endpoint + DNS zone
* Supports secure access without public exposure

---

### 📦 Multi-Environment Deployment

```bash
cd envs/staging     # For test/staging
cd envs/production  # For production

terraform apply -var-file="terraform.tfvars"
```
