-- creating schema

CREATE SCHEMA production;

-- creating table

CREATE TABLE production.sales (
    order_id INTEGER,
    cust_name VARCHAR(255),
    product VARCHAR(255),
    product_category VARCHAR(255),
    quantity INTEGER,
    price DECIMAL(10, 2),
    purchased_at DATE,
    product_id INTEGER,
    customer_id INTEGER,
    order_date_at DATE,
    discount DECIMAL(10, 2),
    shipping_cost DECIMAL(10, 2),
    city VARCHAR(255),
    province VARCHAR(255),
    country VARCHAR(255)
);


-- credentials for airbyte

CREATE USER airbyte_user PASSWORD password;

GRANT USAGE ON SCHEMA production TO airbyte_user;

GRANT SELECT ON ALL TABLES IN SCHEMA production TO airbyte_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA production GRANT SELECT ON TABLES TO airbyte_user;

ALTER USER airbyte_user REPLICATION;