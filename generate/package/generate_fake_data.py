import os
import random
import sys

import pandas as pd
from dotenv import load_dotenv
from faker import Faker
from sqlalchemy import create_engine
from sqlalchemy.exc import OperationalError

# getting connection string for ec2 instance
load_dotenv()
ec2_connection_url = os.getenv('EC2_CONNECTION_URL')

# using Canadian references
fake = Faker("en_CA")

# getting non-determinstic data for every run
seed_num = random.randint(1, 500)
Faker.seed(seed_num)

# number of records
num_records = 50_000

# product categories
product_categories = [
    "Electronics",
    "Clothing",
    "Home & Kitchen",
    "Books",
    "Toys & Games",
]


# generating a pandas DataFrame filled with fake sales data
def generate_fake_data():
    data = []

    for i in range(1, num_records + 1):
        print(f"generating record {i}...")
        order_id = i
        cust_name = fake.name()
        product = fake.bs()  # just generating random product names
        product_category = random.choice(product_categories)
        quantity = random.randint(1, 10)
        price = round(random.uniform(10.5, 200.5), 2)
        purchased_at = fake.date_between(start_date="-1y", end_date="today")
        product_id = random.randint(1000, 2000)
        customer_id = random.randint(1, 500)
        order_date_at = fake.date_between(start_date="-1y", end_date="today")
        discount = round(random.uniform(0.0, 0.3), 2)  # 30% max discount
        shipping_cost = round(random.uniform(5.0, 20.0), 2)
        city = fake.city()
        province = fake.province()
        country = "Canada"

        data.append(
            pd.DataFrame(
                {
                    "order_id": [order_id],
                    "cust_name": [cust_name],
                    "product": [product],
                    "product_category": [product_category],
                    "quantity": [quantity],
                    "price": [price],
                    "purchased_at": [purchased_at],
                    "product_id": [product_id],
                    "customer_id": [customer_id],
                    "order_date_at": [order_date_at],
                    "discount": [discount],
                    "shipping_cost": [shipping_cost],
                    "city": [city],
                    "province": [province],
                    "country": [country],
                }
            )
        )
    print("creating dataframe...")
    df = pd.concat(data, ignore_index=True)
    return df

# attempting to establish a database connection
def create_db_connection():
    try:
        # TODO: update to connect to dynamic ec2 connection string
        engine = create_engine("postgresql://retailflow_admin:retailflow123@localhost:5432/retailflow_db")
        # engine = create_engine(f"postgresql://retailflow_admin:retailflow123@{ec2_connection_url}:5432/retailflow_db")
        print("creating db connection...")
        # Try to connect to the database
        connection = engine.connect()
        connection.close()  # close the connection after it's been tested
        return engine
    except OperationalError:
        print("could not establish a connection with the database. Please check your connection parameters")
        sys.exit(1)

# pushing the data to the database
def push_data_to_db(data, engine, table_name="sales"):
    # TODO: if connection fails, dump data to s3
    data.to_sql(table_name, engine, if_exists="append", index=False)
    print("pushing data to db...")

# running functions
db_data = generate_fake_data()
db_engine = create_db_connection()
push_data_to_db(data=db_data, engine=db_engine)
