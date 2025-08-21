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
