from faker import Faker
import pandas as pd
import random

# using Canadian references
fake = Faker('en_CA')

# number of records
num_records = 50_000

# product categories
product_categories = ['Electronics', 'Clothing', 'Home & Kitchen', 'Books', 'Toys & Games']

def generate_fake_data():
    data = []

    for i in range(1, num_records+1):
        order_id = i
        cust_name = fake.name()
        product = fake.bs()   # just generating random product names
        product_category = random.choice(product_categories)
        quantity = random.randint(1, 10)
        price = round(random.uniform(10.5, 200.5), 2)
        purchased_at = fake.date_between(start_date='-1y', end_date='today')
        product_id = random.randint(1000, 2000)
        customer_id = random.randint(1, 500)
        order_date_at = fake.date_between(start_date='-1y', end_date='today')
        discount = round(random.uniform(0.0, 0.3), 2)  # 30% max discount
        shipping_cost = round(random.uniform(5.0, 20.0), 2)
        city = fake.city()
        province = fake.province() 
        country = 'Canada'

        data.append(pd.DataFrame({'order_id': [order_id],
                                    'cust_name': [cust_name],
                                    'product': [product],
                                    'product_category': [product_category],
                                    'quantity': [quantity],
                                    'price': [price],
                                    'purchased_at': [purchased_at],
                                    'product_id':[product_id],
                                    'customer_id':[customer_id],
                                    'order_date_at':[order_date_at],
                                    'discount':[discount],
                                    'shipping_cost':[shipping_cost],
                                    'city':[city],
                                    'province':[province],
                                    'country':[country]
                                }))
        
    df = pd.concat(data, ignore_index=True)
    return df

def create_db_connection():
    # TODO: use sqlalchemy to create a connection to the postgres running on AWS
    # https://docs.sqlalchemy.org/en/20/core/engines.html
    pass

def push_data_to_db():
    # TODO: use sqlalchemy to push fake data to db 
    # https://docs.sqlalchemy.org/en/20/core/dml.html
    # INSERT INTO sales VALUES([order_id], [cust_name]...);
    pass

result = generate_fake_data()
result.describe()
