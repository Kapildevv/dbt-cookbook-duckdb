# dbt Cookbook projects on DuckDB

The runnable projects behind two books by Kapil Dev V. Every command and
every output printed in the books came from the files in this repository.

| Folder | Book | Engine | Finished build |
|---|---|---|---|
| [`dbt-cookbook/`](dbt-cookbook/) | *Data build tool (dbt) Cookbook: Build a Medallion Warehouse with dbt Core 1.x* — first edition | dbt Core 1.12.0 + dbt-duckdb 1.11.0 | 60 nodes, 1 deliberate warning |
| [`dbt-v2-cookbook/`](dbt-v2-cookbook/) | *Data build tool (dbt) v2 Cookbook: Recipes for Migrating, Building and Shipping a Medallion Warehouse* — second edition | dbt 2.0.6, DuckDB built in | 62 nodes, 1 deliberate warning |

Both folders hold the same warehouse: an Indian e-commerce business with
five raw feeds — customers, products, transactions, payment-gateway
responses and cashback — taken from raw through bronze, silver and gold to
tested, documented marts. It runs on DuckDB, a database that is a single
file on your laptop: no server, no cloud account and no bill.

## Quick start

Pick the folder for your book and follow its README. The short version:

```
cd dbt-cookbook                         # or dbt-v2-cookbook
uv venv --python 3.12 .venv
uv pip install --python .venv "dbt-core==1.12.0" "dbt-duckdb==1.11.0"
#   for dbt-v2-cookbook instead:  uv pip install --python .venv "dbt==2.0.6"
```

Activate the environment (`.venv\Scripts\activate` on Windows,
`source .venv/bin/activate` on macOS and Linux), then:

```
cp profiles_sample.yml profiles.yml
python load_raw.py
dbt build
```

No `uv`? `python -m venv .venv` and `pip install` work the same way.

For the v2 project, `load_raw.py` needs the `duckdb` Python package, which a
v2 environment does not include: `pip install duckdb` in any Python, or use
your 1.12 environment. The v2 README explains why.

**Use the pinned versions.** The books print real output from these exact
releases. A newer dbt will mostly work, but log formats and warnings differ,
so your screen will stop matching the page.

## The data

Everything in `raw_files/` is synthetic. `make_data.py` produces it from a
fixed seed, so running it again gives byte-identical CSVs and the same
numbers as the books. The names, emails and phone numbers are invented.

## Practising on a cloud warehouse

The same five tables, with a larger dataset and different model names, run
on Databricks in a separate practice project:
[github.com/Kapildevv/dbt-data-build-tool-practice](https://github.com/Kapildevv/dbt-data-build-tool-practice).
Its counts will not match the books. This repository is the one the
chapters print.

## Corrections

If an example no longer behaves as printed, please open an issue with the
book, the chapter and what you saw.

## Licence

MIT No Attribution — see [LICENSE](LICENSE). Use the code in your own
projects without restriction or attribution.
