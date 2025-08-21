with orders as (
    select
        order_id,
        customer_id,
        order_date,
        total_amount
    from {{ source('raw', 'orders') }}
)

select * from orders
