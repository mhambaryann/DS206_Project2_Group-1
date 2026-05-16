# DS206 Group Project #2 — Group 3
## Dimensional Data Pipeline: Northwind Orders

A fully automated ETL pipeline that loads source data into a dimensional data store (`ORDER_DDS`) built on SQL Server, orchestrated through Python and executable from the command line.

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Database Design](#database-design)
4. [Setup & Prerequisites](#setup--prerequisites)
5. [Running the Pipeline](#running-the-pipeline)
6. [Running the Tests](#running-the-tests)
7. [Pipeline Architecture](#pipeline-architecture)
8. [SCD Strategy Reference](#scd-strategy-reference)
9. [Team & Contributions](#team--contributions)

---

## Project Overview

This project implements a **dimensional data warehouse** for the Northwind dataset using SQL Server. The pipeline:

- Loads raw source data into **staging tables** inside `ORDER_DDS`
- Applies **Slowly Changing Dimension (SCD)** logic to populate all dimension tables
- Ingests order data into **FactOrders** using a **SNAPSHOT** strategy
- Captures failed rows (missing or invalid natural keys) into **FactOrders_Error**
- Logs every pipeline run with a unique `execution_id` (UUID) to `logs/logs_dimensional_data_pipeline.txt`
- Is fully executable from the command line with a configurable date range

---

## Repository Structure

```
DS206_Project2_Group-3/
│
├── infrastructure_initiation/
│   ├── dimensional_database_creation.sql   # Creates ORDER_DDS database
│   ├── dimensional_db_table_creation.sql   # Creates all dim/fact tables + Dim_SOR
│   └── staging_raw_table_creation.sql      # Creates all staging tables
│
├── pipeline_dimensional_data/
│   ├── flow.py                             # DimensionalDataFlow class
│   ├── tasks.py                            # Flow-specific SQL execution functions
│   ├── config.py                           # Table names and database name constants
│   ├── __init__.py
│   └── queries/
│       ├── update_dim_categories.sql       # SCD1 with delete
│       ├── update_dim_customers.sql        # SCD2
│       ├── update_dim_employees.sql        # SCD1 with delete
│       ├── update_dim_products.sql         # SCD2 with delete (closing)
│       ├── update_dim_region.sql           # SCD1
│       ├── update_dim_shippers.sql         # SCD1
│       ├── update_dim_suppliers.sql        # SCD4
│       ├── update_dim_territories.sql      # SCD3 (current and prior attribute)
│       ├── update_fact.sql                 # SNAPSHOT ingestion into FactOrders
│       └── update_fact_error.sql           # Rejected rows into FactOrders_Error
│
├── logs/
│   └── logs_dimensional_data_pipeline.txt  # Auto-generated pipeline logs
│
├── tests/
│   ├── test_flow.py                        # Tests for DimensionalDataFlow class
│   ├── test_tasks.py                       # Tests for tasks.py functions
│   ├── test_utils.py                       # Tests for utils.py functions
│   └── test_sql_integrity.py               # SQL script integrity checks
│
├── main.py                                 # CLI entry point
├── utils.py                                # Flow-agnostic utility functions
├── pipeline_logging.py                     # Logger setup with execution_id
├── sql_server_config.cfg                   # Database connection configuration
├── requirements.txt                        # Python dependencies
├── pytest.ini                              # pytest configuration
└── .gitignore
```

---

## Database Design

**Database:** `ORDER_DDS`

### Staging Tables

All staging tables live inside `ORDER_DDS` and each includes a `staging_raw_id_sk` (IDENTITY) column for traceability.

| Staging Table |
|---|
| Staging_Categories |
| Staging_Customers |
| Staging_Employees |
| Staging_OrderDetails |
| Staging_Orders |
| Staging_Products |
| Staging_Region |
| Staging_Shippers |
| Staging_Suppliers |
| Staging_Territories |

### Dimension Tables

| Table | SCD Type | Notes |
|---|---|---|
| DimCategories | SCD1 with delete | `IsDeleted` flag for soft deletes |
| DimCustomers | SCD2 | `StartDate`, `EndDate`, `IsCurrent` |
| DimEmployees | SCD1 with delete | `IsDeleted` flag |
| DimProducts | SCD2 with delete (closing) | `IsCurrent`, `IsDeleted`, `EndDate` closed on delete |
| DimRegion | SCD1 | Simple overwrite |
| DimShippers | SCD1 | Simple overwrite |
| DimSuppliers | SCD4 | Current values in main table, history in `DimSuppliers_History` |
| DimTerritories | SCD3 | `TerritoryDescription_Current` and `TerritoryDescription_Prior` |
| Dim_SOR | Static lookup | Maps staging table names to surrogate keys (`staging_table_name`) |

### Fact Tables

| Table | Strategy | Description |
|---|---|---|
| FactOrders | SNAPSHOT | Full replace of the requested date period on each run |
| FactOrders_Error | SNAPSHOT | Rows rejected from FactOrders due to missing dimension keys |

---

## Setup & Prerequisites

### Requirements
- SQL Server (locally or via Azure Data Studio)
- Python 3.8+

Install Python dependencies:

```bash
pip install -r requirements.txt
```

### Step 1 — Database Initialization

Run the following scripts **in order** in Azure Data Studio:

```
1. infrastructure_initiation/dimensional_database_creation.sql
2. infrastructure_initiation/staging_raw_table_creation.sql
3. infrastructure_initiation/dimensional_db_table_creation.sql
```

### Step 2 — Configure the Connection

Edit `sql_server_config.cfg` with your SQL Server connection details:

```ini
[sql_server]
server   = YOUR_SERVER_NAME
database = ORDER_DDS
driver   = ODBC Driver 17 for SQL Server
```

---

## Running the Pipeline

The pipeline is executed from the command line with a start and end date:

```bash
python main.py --start_date=YYYY-MM-DD --end_date=YYYY-MM-DD
```

**Example:**

```bash
python main.py --start_date=1996-01-01 --end_date=1998-12-31
```

This will:
1. Generate a unique `execution_id` (UUID) for the run
2. Execute all dimension update scripts sequentially
3. Ingest data into `FactOrders` for the given period (SNAPSHOT)
4. Capture any rejected rows into `FactOrders_Error`
5. Write structured logs to `logs/logs_dimensional_data_pipeline.txt`

Each task only runs if the previous one succeeded. The pipeline is fully atomic and reproducible — re-running with the same dates produces the same result.

---

## Running the Tests

```bash
pytest tests/ -v
```

The test suite uses `unittest.mock` to simulate the file system and database — no live SQL Server connection required. Coverage includes:

- **`test_utils.py`** — success paths, failure paths (`FileNotFoundError`, `pyodbc.Error`), and edge cases (empty configs, null parameters) for all utility functions
- **`test_tasks.py`** — verifies task functions execute SQL correctly and handle errors gracefully
- **`test_flow.py`** — verifies the `DimensionalDataFlow` class instantiates correctly and the `exec` method runs tasks sequentially
- **`test_sql_integrity.py`** — checks that all SQL scripts exist and are readable

---

## Pipeline Architecture

```
main.py  (CLI: --start_date, --end_date)
    │
    └── DimensionalDataFlow (flow.py)
            │   execution_id = uuid()
            │
            └── exec(start_date, end_date)
                    │
                    ├── Task 1: Update all Dimension tables
                    │       update_dim_categories.sql   (SCD1 with delete)
                    │       update_dim_customers.sql    (SCD2)
                    │       update_dim_employees.sql    (SCD1 with delete)
                    │       update_dim_products.sql     (SCD2 with delete)
                    │       update_dim_region.sql       (SCD1)
                    │       update_dim_shippers.sql     (SCD1)
                    │       update_dim_suppliers.sql    (SCD4)
                    │       update_dim_territories.sql  (SCD3)
                    │
                    ├── Task 2: Ingest FactOrders (SNAPSHOT)
                    │       update_fact.sql
                    │
                    └── Task 3: Ingest FactOrders_Error
                            update_fact_error.sql
```

Tasks run sequentially. Each task returns `{'success': True}` and the next task only runs if its prerequisite succeeded.

---

## SCD Strategy Reference

| Strategy | Behavior |
|---|---|
| SCD1 | Overwrite existing values in place |
| SCD1 with delete | Overwrite + set `IsDeleted = 1` for rows no longer in source |
| SCD2 | Insert a new row, close the old row (`EndDate`, `IsCurrent = 0`) |
| SCD2 with delete (closing) | SCD2 + set `IsDeleted = 1` and close `EndDate` when source row is deleted |
| SCD3 | Keep current and one prior value in the same row |
| SCD4 | Current values in main table, full history in separate `_History` table |
| SNAPSHOT | Delete and re-insert the entire period on each run |

---

## Team & Contributions

| Member | Role | Responsibilities |
|---|---|---|
| Member 1 | Infrastructure & Environment Architect | GitHub setup, `dimensional_database_creation.sql`, `staging_raw_table_creation.sql`, `pipeline_logging.py`, `sql_server_config.cfg`, `logs/` directory |
| Member 2 | Dimensional Modeling & SQL Lead | `dimensional_db_table_creation.sql`, `Dim_SOR`, all `update_dim_*.sql` scripts, surrogate key and SCD design |
| Member 3 | Fact Ingestion & Data Logic Specialist | `update_fact.sql`, `update_fact_error.sql`, `start_date`/`end_date` period logic, error row identification |
| Member 4 | Python Pipeline & Flow Engineer | `flow.py`, `main.py`, `execution_id` UUID tracking, sequential task orchestration |
| Member 5 | Utility, Task & Quality Assurance | `utils.py`, `tasks.py`, `config.py`, full test suite in `tests/`, pytest + mocking |
