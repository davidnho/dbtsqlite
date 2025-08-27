Perfect 👍 Let’s build a **DBT project with SQLite** that uses **CSV files as source data** and creates a **data model showing relationships between tables** (like Customers → Orders → OrderItems). I’ll walk you through **end-to-end setup**, including YAML configs.

---

## 1. Project Setup

First, install DBT with SQLite adapter:

```bash
pip install dbt-core dbt-sqlite
```

Create a new dbt project:

```bash
dbt init dbt_sqlite_project
```

Inside the project, configure SQLite connection in `profiles.yml` (usually located at `~/.dbt/profiles.yml`):

```yaml
dbt_sqlite_project:
  target: dev
  outputs:
    dev:
      type: sqlite
      threads: 1
      database: ./dbt_sqlite_project/target/mydb.db   # SQLite DB file
      schema: main
```

---

## 2. Source Data (CSV files)

Let’s assume you have these CSV files in a `/data` folder:

* `customers.csv`
* `orders.csv`
* `order_items.csv`

Example contents:

**customers.csv**

```csv
customer_id,customer_name,city
1,John Doe,New York
2,Jane Smith,Los Angeles
```

**orders.csv**

```csv
order_id,customer_id,order_date,total_amount
101,1,2023-01-01,150
102,2,2023-01-05,200
```

**order\_items.csv**

```csv
order_item_id,order_id,product,quantity,price
1001,101,Keyboard,1,50
1002,101,Mouse,2,50
1003,102,Laptop,1,200
```

---

## 3. Load CSVs into SQLite (Seeds in dbt)

DBT can treat CSVs as **seeds**. Place CSVs under `/seeds` folder.

Directory:

```
dbt_sqlite_project/
 ├── models/
 ├── seeds/
 │   ├── customers.csv
 │   ├── orders.csv
 │   └── order_items.csv
```

Run:

```bash
dbt seed
```

👉 This loads CSV data into your SQLite DB as tables: `customers`, `orders`, `order_items`.

---

## 4. Define Sources in YAML

Create a `schema.yml` under `models/`:

```yaml
version: 2

sources:
  - name: raw
    schema: main
    tables:
      - name: customers
      - name: orders
      - name: order_items

models:
  - name: stg_customers
    description: "Cleaned up customers data"
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
  - name: stg_orders
    description: "Orders with cleaned fields"
  - name: stg_order_items
    description: "Order items details"
```

---

## 5. Create Staging Models (SQL files)

Inside `/models/staging/`:

**stg\_customers.sql**

```sql
with customers as (
    select
        customer_id,
        customer_name,
        city
    from {{ source('raw', 'customers') }}
)

select * from customers
```

**stg\_orders.sql**

```sql
with orders as (
    select
        order_id,
        customer_id,
        order_date,
        total_amount
    from {{ source('raw', 'orders') }}
)

select * from orders
```

**stg\_order\_items.sql**

```sql
with order_items as (
    select
        order_item_id,
        order_id,
        product,
        quantity,
        price
    from {{ source('raw', 'order_items') }}
)

select * from order_items
```

---

## 6. Build Relationships in a Fact Table

Example: **fact\_orders.sql**

```sql
with o as (
    select * from {{ ref('stg_orders') }}
),
c as (
    select * from {{ ref('stg_customers') }}
),
oi as (
    select * from {{ ref('stg_order_items') }}
)

select
    o.order_id,
    o.order_date,
    c.customer_name,
    c.city,
    sum(oi.quantity * oi.price) as calculated_amount,
    o.total_amount
from o
join c on o.customer_id = c.customer_id
join oi on o.order_id = oi.order_id
group by o.order_id, o.order_date, c.customer_name, c.city, o.total_amount
```

This demonstrates relationships:

* `customers.customer_id → orders.customer_id`
* `orders.order_id → order_items.order_id`

---

## 7. Run the Models

```bash
dbt run
```

You’ll now have:

* `stg_customers`
* `stg_orders`
* `stg_order_items`
* `fact_orders`

---

✅ **Summary of YAML setup**

* Use `seeds` to load CSV → SQLite tables
* Use `sources:` in YAML to declare them
* Use `ref()` and `source()` in SQL models to build relationships
* Fact models aggregate/join to demonstrate relationships

---

Do you want me to also **add relationship tests in YAML** (dbt tests for referential integrity, like `relationships` test between orders and customers)?
