# The project from *Data build tool (dbt) Cookbook* (first edition)

This is the medallion warehouse the book builds, as it stands at the end of
chapter 13 — with the changes that make it ready for dbt v2 already
applied. Every output printed in the book came from this project.

Verified against **dbt Core 1.12.0** with **dbt-duckdb 1.11.0** on Python
3.12. The finished build:

```
Done. PASS=59 WARN=1 ERROR=0 SKIP=0 NO-OP=0 REUSED=0 TOTAL=60
```

The one warning is deliberate — see chapter 7.

## Running it

```
uv venv --python 3.12 .venv
uv pip install --python .venv "dbt-core==1.12.0" "dbt-duckdb==1.11.0"
```

Activate the environment (`.venv\Scripts\activate` on Windows,
`source .venv/bin/activate` on macOS and Linux), then:

```
cp profiles_sample.yml profiles.yml    # chapter 1: profiles.yml stays out of git
python load_raw.py                     # land raw_files/*.csv in DuckDB's raw schema
dbt build
```

`raw_files/` is committed, so you can load straight away.
`python make_data.py` regenerates it, byte for byte, from a fixed seed.

## What is where

| Path | Chapter |
|---|---|
| `profiles_sample.yml` | 1 — where the connection lives |
| `dbt_project.yml` | 2 — every key, and configuring by folder |
| `load_raw.py`, `models/source/sources.yml` | 3 — landing raw data, sources and freshness |
| `seeds/` | 4 — the status mapping |
| `macros/generate_schema_name.sql` | 6 — literal `bronze`, `silver`, `gold` schemas |
| `models/bronze/` | 7 — faithful views |
| `models/silver/`, `macros/json_field.sql` | 8 — typing, JSON and the business rules |
| `models/gold/` | 9 — facts, dimensions and aggregates |
| `macros/multiply.sql`, `analyses/jinja_tour.sql` | 10 — Jinja and macros |
| `models/*/properties.yml`, `models/docs.md` | 11 — properties and doc blocks |
| `tests/` | 12 — custom generic and singular tests |
| `snapshots/snap_payments.sql` | 13 — history the source overwrites |

`dbt build` on its own runs seeds, models, the snapshot and tests in
dependency order — chapter 13 explains why it is the one to schedule.

The second edition's project, on dbt v2, is in `../dbt-v2-cookbook`.
