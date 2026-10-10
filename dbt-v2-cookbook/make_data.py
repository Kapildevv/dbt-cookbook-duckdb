"""Generate the book's raw dataset.

Deterministic: a fixed seed, so every reader who runs this gets byte-identical
CSVs and therefore the same numbers as the printed output.

Shape mirrors a real Indian e-commerce feed: five tables, three of which carry
a JSON metadata column, dates as strings, and a status vocabulary that needs
mapping. That messiness is the point -- it is what the silver layer is for.

    python make_data.py [output_dir]      # default: raw_files/ beside this script
"""

from __future__ import annotations

import csv
import json
import random
import sys
from datetime import datetime, timedelta
from pathlib import Path

SEED = 20260920
random.seed(SEED)

FIRST = ["Isaac", "Anvi", "Rohan", "Meera", "Arjun", "Divya", "Kabir", "Nisha",
         "Vikram", "Priya", "Aditya", "Sneha", "Rahul", "Ananya", "Karan"]
LAST = ["Bakshi", "Konda", "Iyer", "Nair", "Chopra", "Reddy", "Menon", "Gupta",
        "Rao", "Sharma", "Patel", "Bose", "Verma", "Joshi", "Kaur"]
CITIES = [("Chennai", "Tamil Nadu", "6000"), ("Bengaluru", "Karnataka", "5600"),
          ("Mumbai", "Maharashtra", "4000"), ("Pune", "Maharashtra", "4110"),
          ("Hyderabad", "Telangana", "5000"), ("Delhi", "Delhi", "1100")]
DOMAINS = ["gmail.com", "rediffmail.com", "outlook.com", "yahoo.in"]
DEVICES = ["Web", "Android", "iOS"]

PRODUCTS = [
    ("boAt Airdopes 141 True Wireless Earbuds", "Electronics", "boAt", 1299.0),
    ("boAt Stone 650 10W Bluetooth Speaker", "Electronics", "boAt", 1999.0),
    ("Noise ColorFit Pro 4 Smartwatch", "Electronics", "Noise", 2499.0),
    ("Redmi 12 5G 128GB", "Electronics", "Redmi", 13999.0),
    ("Prestige Induction Cooktop 1900W", "Home & Kitchen", "Prestige", 2799.0),
    ("Milton Thermosteel Flask 1L", "Home & Kitchen", "Milton", 1099.0),
    ("Cello Checkers Plastic Chair", "Home & Kitchen", "Cello", 1549.0),
    ("Allen Solly Men's Slim Fit Shirt", "Fashion", "Allen Solly", 1399.0),
    ("Puma Softride Running Shoes", "Fashion", "Puma", 3299.0),
    ("Fastrack Analog Watch", "Fashion", "Fastrack", 1795.0),
    ("Himalaya Neem Face Wash 300ml", "Beauty", "Himalaya", 349.0),
    ("Mamaearth Onion Hair Oil 250ml", "Beauty", "Mamaearth", 599.0),
    ("Amul Pure Ghee 1L", "Grocery", "Amul", 649.0),
    ("Tata Sampann Toor Dal 5kg", "Grocery", "Tata", 899.0),
    ("Classmate Notebook Pack of 6", "Stationery", "Classmate", 299.0),
]

STATUSES = ["Delivered", "Delivered", "Delivered", "InTransit", "Cancelled"]
PAY_METHODS = ["UPI", "Debit Card", "Credit Card", "Net Banking", "Wallet"]
GATEWAYS = ["Razorpay", "BillDesk", "PayU", "Cashfree"]
BANKS = ["HDFC", "ICICI", "SBIN", "AXIS", "KOTAK"]


def ts(base: datetime, days: int) -> str:
    moment = base + timedelta(
        days=days, hours=random.randint(0, 23),
        minutes=random.randint(0, 59), seconds=random.randint(0, 59))
    return moment.strftime("%Y-%m-%d %H:%M:%S")


def main(out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    start = datetime(2026, 4, 1)

    # ---- customers --------------------------------------------------------
    customers = []
    for i in range(60):
        cid = f"CUST-{1001 + i}"
        first, last = random.choice(FIRST), random.choice(LAST)
        city, state, pin_prefix = random.choice(CITIES)
        pincode = f"{pin_prefix}{random.randint(10, 99)}"
        meta = {
            "device_type": random.choice(DEVICES),
            "address_state": state,
            "city": city,
            "pincode": pincode,
            "address": {"address_state": state, "city": city,
                        "pincode": pincode},
            "app_version": f"v{random.randint(9, 12)}."
                           f"{random.randint(0, 9)}.{random.randint(0, 20)}",
            "locale": "en_IN",
        }
        customers.append({
            "customer_id": cid,
            "first_name": first,
            "last_name": last,
            # A small share have no email. The silver layer must cope.
            "email": "" if i % 17 == 0 else
                     f"{first.lower()}.{last.lower()}{random.randint(100, 999)}"
                     f"@{random.choice(DOMAINS)}",
            "phone_number": f"+91-{random.randint(6000000000, 9999999999)}",
            "registration_date": (start - timedelta(
                days=random.randint(30, 900))).strftime("%Y-%m-%d"),
            "customer_metadata": json.dumps(meta),
        })

    # The source re-sends a whole row when a field is corrected, so one
    # customer arrives twice with the same id and a fixed-up email. The
    # silver layer must collapse it; see the deduplication recipe.
    resend = dict(customers[0])
    resend["email"] = (f'{resend["first_name"].lower()}.'
                       f'{resend["last_name"].lower()}@corrected.example.com')
    customers.append(resend)

    # ---- products ---------------------------------------------------------
    products = []
    for i, (name, cat, brand, price) in enumerate(PRODUCTS):
        specs = {
            "weight_grams": random.choice([45, 250, 400, 650, 1200]),
            "warranty_months": random.choice([0, 6, 12, 24]),
            "is_returnable": random.choice([True, True, False]),
            "model_code": f"MOD-{random.randint(1000, 9999)}",
        }
        products.append({
            "product_id": f"PROD-{5001 + i}",
            "product_name": name,
            "category": cat,
            "brand": brand,
            "base_price": price,
            "product_specs": json.dumps(specs),
        })

    # ---- transactions -----------------------------------------------------
    transactions = []
    for i in range(200):
        prod = random.choice(products)
        qty = random.choice([1, 1, 1, 2, 2, 3])
        transactions.append({
            "order_id": f"ORD-{90001 + i}",
            "customer_id": random.choice(customers)["customer_id"],
            "product_id": prod["product_id"],
            "order_date": ts(start, random.randint(0, 29)),
            "quantity": qty,
            "total_amount": round(prod["base_price"] * qty, 2),
            "order_status": random.choice(STATUSES),
        })

    # ---- payments ---------------------------------------------------------
    payments = []
    for i, txn in enumerate(transactions):
        failed = txn["order_status"] == "Cancelled" and random.random() < 0.5
        meta = {
            "bank_reference_no": f"{random.choice(BANKS)}"
                                 f"{random.randint(1000000000, 9999999999)}",
            "error_code": "ERR_TIMEOUT" if failed else None,
            "processing_fee_inr": round(random.uniform(0, 30), 2),
            "merchant_vpa": random.choice(
                ["flipmyntra@icici", "flipmyntra@hdfc", None]),
            "ip_address": ".".join(
                str(random.randint(1, 254)) for _ in range(4)),
        }
        payments.append({
            "payment_id": f"PAY-{4001 + i}",
            "order_id": txn["order_id"],
            "payment_method": random.choice(PAY_METHODS),
            "gateway_name": random.choice(GATEWAYS),
            "payment_status": "Failed" if failed else "Success",
            "pg_metadata": json.dumps(meta),
        })

    # ---- cashback rewards -------------------------------------------------
    # Only some orders earn cashback, so the join must be a LEFT join.
    rewards = []
    for i, txn in enumerate(t for t in transactions if random.random() < 0.5):
        rewards.append({
            "reward_id": f"REW-{7001 + i}",
            "order_id": txn["order_id"],
            "cashback_amount": round(txn["total_amount"] * 0.05, 2),
            "crediting_date": ts(start, random.randint(1, 32)),
            "status": random.choice(["Credited", "Credited", "Pending"]),
        })

    tables = {
        "customers.csv": customers,
        "products.csv": products,
        "transactions.csv": transactions,
        "pg_data.csv": payments,
        "cashback_rewards.csv": rewards,
    }
    for name, rows in tables.items():
        path = out_dir / name
        with path.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=list(rows[0]))
            writer.writeheader()
            writer.writerows(rows)
        print(f"{name}: {len(rows)} rows")

    # The status vocabulary the business uses, mapped to its internal codes.
    with (out_dir / "mapping.csv").open("w", newline="",
                                        encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["status_text", "status_code"])
        w.writerows([["Delivered", 7], ["Cancelled", 18], ["InTransit", 5]])
    print("mapping.csv: 3 rows")


if __name__ == "__main__":
    # Default to raw_files/ beside this script, which is where load_raw.py reads.
    main(Path(sys.argv[1]) if len(sys.argv) > 1
         else Path(__file__).resolve().parent / "raw_files")
