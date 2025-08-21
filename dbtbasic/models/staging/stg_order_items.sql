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
