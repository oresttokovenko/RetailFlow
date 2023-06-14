with source as (

    select * from {{ source('prod_postgresql', 'sales') }}

)

, renamed as (

    select
        order_id
        , cust_name
        , product
        , product_category
        , quantity
        , province
        , purchased_at
        , product_id
        , customer_id
        , order_date_at
        , discount
        , shipping_cost
        , city
        , province
        , country
    from source

)

select * from renamed
