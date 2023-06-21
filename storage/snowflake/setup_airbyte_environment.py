from sqlalchemy import create_engine
from dotenv import load_dotenv
import pathlib
import os

sql_file_path = pathlib.Path("storage/snowflake/airbyte_environment_setup.sql")

with sql_file_path.open() as f:
    sql_script = f.read()

# getting connection string for snowflake instance
load_dotenv()
user = os.getenv('SNOWFLAKE_USERNAME')
password = os.getenv('SNOWFLAKE_PASSWORD')
account_identifier = os.getenv('SNOWFLAKE_ACCOUNT_ID')

engine = create_engine(f'snowflake://{user}:{password}@{account_identifier}/')

try:
    connection = engine.connect()
    results = connection.execute('select current_version()').fetchone() # 
    print(results[0])
    # connection.execute(sql_script)
finally:
    connection.close()
    engine.dispose()