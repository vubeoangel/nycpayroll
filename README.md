# NYC Payroll Data Engineering Pipeline

An end-to-end cloud data engineering pipeline built on **Microsoft Azure**, demonstrating automated ETL, multi-source ingestion, data warehousing, and analytical querying at scale.

> This project applies data engineering methodology comparable to Australian public sector payroll analytics — directly transferable to ABS workforce datasets and state government agency reporting pipelines.

---

## Architecture

```
[Raw CSV Files — 5 sources]
  AgencyMaster | EmpMaster | TitleMaster | Payroll2020 | Payroll2021
                            ↓
              [Azure Data Lake Gen2]
                raw-data/ container
                            ↓
              [Azure Data Factory]
           PL_NYCPayroll — 6 Data Flows
          ┌──────────────────────────────┐
          │  DF_AgencyMaster  → SQL DB   │
          │  DF_EmpMaster     → SQL DB   │  (parallel)
          │  DF_TitleMaster   → SQL DB   │
          │  DF_Payroll2020   → SQL DB   │  (parallel)
          │  DF_Payroll2021   → SQL DB   │
          │          ↓                   │
          │  DF_PayrollSummary           │
          │    Union → Aggregate         │
          │    → SQL Summary table       │
          │    → staging/ (Parquet)      │
          └──────────────────────────────┘
                    ↓               ↓
          [Azure SQL Database]   [Staging Parquet]
                                      ↓
                         [Azure Synapse Analytics]
                           CETAS External Table
```

---

## Tech Stack

| Layer | Azure Service | Role |
|---|---|---|
| Storage | Azure Data Lake Gen2 | Raw CSV + Parquet staging |
| ETL | Azure Data Factory (V2) | Pipeline orchestration + transformation |
| Warehouse | Azure SQL Database (Serverless) | Structured relational storage |
| Analytics | Azure Synapse Analytics | Serverless SQL + CETAS external tables |

All resources deployed in **Australia East** region.

---

## Repo Structure

```
├── configs/                        # ADF ARM templates (importable)
│   ├── ARMTemplateForFactory.json  # Full pipeline definition
│   ├── ARMTemplateParametersForFactory.json
│   └── linkedTemplates/            # Modular ARM components
├── data/                           # Source CSV files
│   ├── AgencyMaster.csv
│   ├── EmpMaster.csv
│   ├── TitleMaster.csv
│   ├── nycpayroll_2020.csv
│   └── nycpayroll_2021.csv
├── scripts/
│   ├── table_initialization.sql   # SQL DB table creation
│   └── synapse_external_table.sql # Synapse CETAS external table
└── resources/                      # Pipeline screenshots
```

---

## ADF Components

### Linked Services
| Name | Type |
|---|---|
| `LS_Datalake` | Azure Data Lake Storage Gen2 |
| `LS_SQLDatabase` | Azure SQL Database |

### Datasets (12 total)
| Dataset | Type | Points To |
|---|---|---|
| DS_AgencyMaster | CSV (ADLS) | raw-data/AgencyMaster.csv |
| DS_EmpMaster | CSV (ADLS) | raw-data/EmpMaster.csv |
| DS_TitleMaster | CSV (ADLS) | raw-data/TitleMaster.csv |
| DS_Payroll2020 | CSV (ADLS) | raw-data/nycpayroll_2020.csv |
| DS_Payroll2021 | CSV (ADLS) | raw-data/nycpayroll_2021.csv |
| DS_Staging | Parquet (ADLS) | staging/ container |
| DS_SQL_AgencyMaster | Azure SQL | dbo.NYC_Payroll_AGENCY_MD |
| DS_SQL_EmpMaster | Azure SQL | dbo.NYC_Payroll_EMP_MD |
| DS_SQL_TitleMaster | Azure SQL | dbo.NYC_Payroll_TITLE_MD |
| DS_SQL_Payroll2020 | Azure SQL | dbo.NYC_Payroll_Data_2020 |
| DS_SQL_Payroll2021 | Azure SQL | dbo.NYC_Payroll_Data_2021 |
| DS_SQL_Summary | Azure SQL | dbo.NYC_Payroll_Summary |

### Data Flows

| Data Flow | Transform | Source → Sink |
|---|---|---|
| DF_AgencyMaster | Load | DS_AgencyMaster → DS_SQL_AgencyMaster |
| DF_EmpMaster | Load | DS_EmpMaster → DS_SQL_EmpMaster |
| DF_TitleMaster | Load | DS_TitleMaster → DS_SQL_TitleMaster |
| DF_Payroll2020 | Load | DS_Payroll2020 → DS_SQL_Payroll2020 |
| DF_Payroll2021 | Load | DS_Payroll2021 → DS_SQL_Payroll2021 |
| DF_PayrollSummary | Union → Aggregate | Payroll2020 + Payroll2021 → SQL Summary + Staging |

### Aggregation Logic (DF_PayrollSummary)

```
Payroll2020 ──┐
              ├── Union ──→ Aggregate by (AgencyName, FiscalYear)
Payroll2021 ──┘            SUM(BaseSalary + RegularGrossPaid + TotalOTPaid + TotalOtherPay)
                           ──→ NYC_Payroll_Summary (SQL)
                           ──→ staging/ (Parquet files)
```

---

## SQL Database Schema

See [`scripts/table_initialization.sql`](scripts/table_initialization.sql) for full DDL.

```sql
NYC_Payroll_AGENCY_MD    -- AgencyID, AgencyName
NYC_Payroll_EMP_MD       -- EmployeeID, LastName, FirstName
NYC_Payroll_TITLE_MD     -- TitleCode, TitleDescription
NYC_Payroll_Data_2020    -- 19 columns: FiscalYear → TotalOtherPay
NYC_Payroll_Data_2021    -- same schema as 2020
NYC_Payroll_Summary      -- FiscalYear, AgencyName, TotalPaid
```

---

## Synapse Analytics — CETAS External Table

```sql
-- Create external data source pointing to staging folder
CREATE EXTERNAL DATA SOURCE nyc_staging
WITH (
    LOCATION = 'abfss://staging@<storage_account>.dfs.core.windows.net/'
);

-- Create file format
CREATE EXTERNAL FILE FORMAT parquet_format
WITH ( FORMAT_TYPE = PARQUET );

-- Create external table (no data copy — queries Parquet directly)
CREATE EXTERNAL TABLE NYC_Payroll_Summary_Ext (
    FiscalYear  VARCHAR(8000),
    AgencyName  VARCHAR(8000),
    TotalPaid   VARCHAR(8000)
)
WITH (
    LOCATION    = '/',
    DATA_SOURCE = nyc_staging,
    FILE_FORMAT = parquet_format
);
```

### Query Results

```sql
SELECT * FROM NYC_Payroll_Summary_Ext ORDER BY FiscalYear, AgencyName;
```

| FiscalYear | AgencyName | TotalPaid |
|---|---|---|
| 2020 | OFFICE OF EMERGENCY MANAGEMENT | 11,071,613.95 |
| 2020 | OFFICE OF MANAGEMENT & BUDGET | 5,023,443.32 |
| 2021 | BOARD OF ELECTION | 389,758.09 |
| 2021 | CAMPAIGN FINANCE BOARD | 458,588.60 |
| 2021 | POLICE DEPARTMENT | 258,609.20 |

---

## Pipeline Screenshots

| Screenshot | Description |
|---|---|
| ![Data Flow](resources/Screenshot%202026-06-14%20at%202.19.41%20pm.png) | DF_AgencyMaster — Source → Sink |
| ![Pipeline Canvas](resources/Screenshot%202026-06-14%20at%203.03.47%20pm.png) | PL_NYCPayroll pipeline canvas |
| ![Pipeline Run](resources/Screenshot%202026-06-14%20at%203.04.07%20pm.png) | Pipeline run — all activities succeeded |
| ![SQL Results](resources/Screenshot%202026-06-14%20at%203.24.41%20pm.png) | SQL DB query — NYC_Payroll_Summary |
| ![Row Counts](resources/Screenshot%202026-06-14%20at%203.24.52%20pm.png) | Row count verification |

---

## How to Reproduce

**Prerequisites:** Azure subscription (Azure for Students free tier works)

1. Create Resource Group in `Australia East`
2. Provision resources:
   - Storage Account → enable **Hierarchical Namespace** (ADLS Gen2)
   - Azure SQL Server + Database (Serverless free tier)
   - Azure Data Factory (V2)
   - Azure Synapse Analytics Workspace → link to Storage Account
3. Create containers: `raw-data` and `staging` in Storage Account
4. Upload `/data/*.csv` to `raw-data/` container
5. Run `scripts/table_initialization.sql` in SQL DB Query Editor
6. Import ADF ARM template from `configs/ARMTemplateForFactory.json`
7. Update Linked Service credentials (Storage Account key + SQL credentials)
8. Trigger `PL_NYCPayroll` pipeline
9. Create Synapse external table using CETAS script above

---

## Key Technical Concepts Demonstrated

**ADLS Gen2 vs Blob Storage** — hierarchical namespace enables directory-level ACLs essential for multi-tenant data lake patterns

**ADF Managed Identity auth** — service-to-service authentication via system-assigned managed identity; requires `Storage Blob Data Contributor` IAM role assignment

**Parquet for staging** — columnar format enables predicate pushdown in Synapse; Snappy compression reduces staging storage ~5-10x vs CSV

**CETAS (Create External Table As Select)** — Lakehouse pattern decoupling storage from compute; data persists in Data Lake, Synapse queries externally without ingestion

**Serverless SQL pool** — consumption-based pricing; auto-pause on inactivity suitable for intermittent analytical workloads

---

## Author

**Sebastian Nguyen** — Master of IT (Data Analytics), University of Technology Sydney

GitHub: [vubeoangel](https://github.com/vubeoangel) | Portfolio: [vubeoangel.github.io/portfolio](https://vubeoangel.github.io/portfolio)
