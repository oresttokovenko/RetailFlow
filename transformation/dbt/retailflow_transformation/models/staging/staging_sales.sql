with source as (

    select * from {{ source('postgres_prod', 'sales') }}

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
