-- ============================================
-- Synapse Analytics — CETAS External Table
-- Database: nyc_payroll_db (Serverless SQL Pool)
-- ============================================

-- Step 1: Create database
CREATE DATABASE nyc_payroll_db;

-- Step 2: Switch to nyc_payroll_db, then run below

-- Step 3: Create external data source pointing to staging folder
CREATE EXTERNAL DATA SOURCE nyc_staging
WITH (
    LOCATION = 'abfss://staging@<your-storage-account>.dfs.core.windows.net/'
);

-- Step 4: Create Parquet file format
CREATE EXTERNAL FILE FORMAT parquet_format
WITH (
    FORMAT_TYPE = PARQUET
);

-- Step 5: Create external table (no data copy — queries Parquet files directly)
CREATE EXTERNAL TABLE NYC_Payroll_Summary_Ext (
    FiscalYear    VARCHAR(8000),
    AgencyName    VARCHAR(8000),
    TotalPaid     VARCHAR(8000)
)
WITH (
    LOCATION    = '/',
    DATA_SOURCE = nyc_staging,
    FILE_FORMAT = parquet_format
);

-- Step 6: Query
SELECT * FROM NYC_Payroll_Summary_Ext
ORDER BY FiscalYear, AgencyName;
