from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
QUERY_DIR = PROJECT_ROOT / "pipeline_dimensional_data" / "queries"

DB_NAME = "ORDER_DDS"
SCHEMA_NAME = "dbo"

DIMENSION_TABLES = {
    "categories": "DimCategories",
    "customers": "DimCustomers",
    "employees": "DimEmployees",
    "products": "DimProducts",
    "region": "DimRegion",
    "shippers": "DimShippers",
    "suppliers": "DimSuppliers",
    "territories": "DimTerritories",
}

FACT_TABLE = "FactOrders"
ERROR_TABLE = "FactOrders_Error"

DIMENSION_QUERY_PATHS = {
    "categories": QUERY_DIR / "update_dim_categories.sql",
    "customers": QUERY_DIR / "update_dim_customers.sql",
    "employees": QUERY_DIR / "update_dim_employees.sql",
    "products": QUERY_DIR / "update_dim_products.sql",
    "region": QUERY_DIR / "update_dim_region.sql",
    "shippers": QUERY_DIR / "update_dim_shippers.sql",
    "suppliers": QUERY_DIR / "update_dim_suppliers.sql",
    "territories": QUERY_DIR / "update_dim_territories.sql",
}

FACT_QUERY_PATH = QUERY_DIR / "update_fact.sql"
FACT_ERROR_QUERY_PATH = QUERY_DIR / "update_fact_error.sql"

FACT_QUERY_PARAMS = {
    "db_name": DB_NAME,
    "schema_name": SCHEMA_NAME,
    "fact_table": FACT_TABLE,
}

FACT_ERROR_QUERY_PARAMS = {
    "db_name": DB_NAME,
    "schema_name": SCHEMA_NAME,
    "error_table": ERROR_TABLE,
}
