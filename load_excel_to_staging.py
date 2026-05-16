import pandas as pd
from utils import get_db_connection

EXCEL_FILE = "/home/margarita/Downloads/raw_data_source.xlsx"

# Map: SQL staging table -> Excel sheet name
TABLE_SHEET_MAP = {
    "dbo.Staging_Categories": "Categories",
    "dbo.Staging_Customers": "Customers",
    "dbo.Staging_Employees": "Employees",
    "dbo.Staging_Products": "Products",
    "dbo.Staging_Region": "Region",
    "dbo.Staging_Shippers": "Shippers",
    "dbo.Staging_Suppliers": "Suppliers",
    "dbo.Staging_Territories": "Territories"
}

def load_sheet_to_table(cursor, excel_file, sheet_name, table_name):
    print(f"\nLoading sheet '{sheet_name}' into table '{table_name}'")

    # Read Excel sheet
    df = pd.read_excel(excel_file, sheet_name=sheet_name)

    # Remove empty rows
    df = df.dropna(how="all")

    # Convert column names
    columns = list(df.columns)

    # Build SQL query
    column_sql = ", ".join(f"[{col}]" for col in columns)
    placeholders = ", ".join(["?"] * len(columns))

    # Clear old data
    cursor.execute(f"DELETE FROM {table_name}")

    # Insert rows
    for _, row in df.iterrows():
        values = [None if pd.isna(v) else v for v in row]

        insert_query = f"""
            INSERT INTO {table_name} ({column_sql})
            VALUES ({placeholders})
        """

        cursor.execute(insert_query, values)

    print(f"Inserted {len(df)} rows into {table_name}")


def main():
    print("Connecting to SQL Server...")

    conn = get_db_connection()
    cursor = conn.cursor()

    for table_name, sheet_name in TABLE_SHEET_MAP.items():
        load_sheet_to_table(
            cursor,
            EXCEL_FILE,
            sheet_name,
            table_name
        )

    conn.commit()

    cursor.close()
    conn.close()

    print("\nExcel data successfully loaded into staging tables.")


if __name__ == "__main__":
    main()
