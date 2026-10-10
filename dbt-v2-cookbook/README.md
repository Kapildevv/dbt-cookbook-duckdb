# The project from *dbt v2 Cookbook* (second edition)

This is the medallion warehouse the book builds and operates, exactly as it
stood when every output in chapters 1 to 17 was captured.

Verified against **dbt 2.0.6**. The finished build:

```
Processed: 14 models | 45 tests | 1 snapshot | 1 seed | 1 unit test | 3 checks
Summary: 62 total | 61 success | 1 warn
```

The one warning is deliberate — see chapter 4.

## Running it

```
uv venv --python 3.12 .venv
uv pip install --python .venv "dbt==2.0.6"
```

Activate the environment (`.venv\Scripts\activate` on Windows,
`source .venv/bin/activate` on macOS and Linux), then:

```
cp profiles_sample.yml profiles.yml    # profiles.yml stays out of git
python load_raw.py                     # land raw_files/*.csv in DuckDB's raw schema
dbt build
```

`raw_files/` is committed, so you can load straight away.
`python make_data.py` regenerates it, byte for byte, from a fixed seed.

`load_raw.py` needs the `duckdb` Python package, which your v2 environment
does not have — v2's DuckDB lives inside the Rust binary and is not
importable from Python. Run it from any Python with `pip install duckdb`.
It is a one-time landing step, not part of the dbt run.

## What is where

| Path | Chapter |
|---|---|
| `dbt_project.yml` | 5 — every key, and the three config tiers |
| `models/source/sources.yml` | 6, 8 — declarations; `config:`-nested freshness |
| `seeds/` | 6 — the status mapping, and what `dbt seed` really does |
| `models/bronze/` | 8 — faithful views |
| `models/silver/` | 8, 11 — cleaned; `silver_transactions` is incremental |
| `models/gold/` | 9, 10 — grain and joins; then contracts |
| `models/groups.yml` | 10 — the layer border |
| `analyses/jinja_tour.sql` | 12 — Jinja, compiled and read |
| `macros/json_field.sql` | 8, 12, 18 — the one warehouse-specific function |
| `macros/multiply.sql` | 12 — the mechanics: Jinja returns SQL text |
| `macros/generate_contract.sql` | 10, 12 — a contract read from the warehouse |
| `macros/generate_schema_name.sql` | 4, 12 — overriding one of dbt's own |
| `models/*/properties.yml` | 13 — descriptions, tests, per-model config |
| `models/gold/unit_tests.yml` | 14 — segment boundaries |
| `tests/` | 14 — singular tests, including the reconciliation test |
| `snapshots/` | 14 — SCD2 on payment status |
| `checks/` | 16 — project rules as SQL |
| `.sqlfluff` | 16 — lint configuration, with reasons |

`dbt_project.yml` sets `+static_analysis: baseline` at the root and
`strict` on gold. **Read chapter 3 before changing that** — the CLI flag
cannot raise it.

The first edition's project, on dbt Core 1.12, is in `../dbt-cookbook`.
Chapter 2 migrates that project; chapters 10 to 17 add the groups,
contracts, unit test, incremental model and checks you find here.
