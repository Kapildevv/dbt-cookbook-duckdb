"""Land the raw CSVs in DuckDB, the way an EL tool would.

dbt does not do extract-and-load. Sources describe tables that something
else put there, so this script stands in for Fivetran, Airbyte or a nightly
COPY INTO. Run it once before the first dbt run.

    python load_raw.py
"""
from pathlib import Path

import duckdb

HERE = Path(__file__).resolve().parent
DB = HERE / "ecom.duckdb"
TABLES = ["customers", "products", "transactions", "pg_data",
          "cashback_rewards"]

con = duckdb.connect(str(DB))
con.execute("create schema if not exists raw")
for name in TABLES:
    csv_path = (HERE / "raw_files" / f"{name}.csv").as_posix()
    con.execute(f"create or replace table raw.{name} as "
                f"select * from read_csv_auto('{csv_path}', "
                f"header=true, all_varchar=true)")
    n = con.execute(f"select count(*) from raw.{name}").fetchone()[0]
    print(f"raw.{name}: {n} rows")
con.close()
