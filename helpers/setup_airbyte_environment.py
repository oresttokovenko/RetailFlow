from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

SQLALCHEMY_SILENCE_UBER_WARNING=1

def get_engine():
    # getting connection string for snowflake instance
    load_dotenv()
    user = os.getenv("SNOWFLAKE_USERNAME")
    password = os.getenv("SNOWFLAKE_PASSWORD")
    account_identifier = os.getenv("SNOWFLAKE_ACCOUNT_ID")

    return create_engine(f"snowflake://{user}:{password}@{account_identifier}/")

def execute_queries(engine):
    # if you plan to use explicit transactions, you must disable the AUTOCOMMIT execution option
    with engine.connect().execution_options(autocommit=False) as connection:
        try:
            # set variables (these need to be uppercase)
            connection.execute("SET airbyte_role = 'AIRBYTE_ROLE'")
            connection.execute("SET airbyte_username = 'AIRBYTE_USER'")
            connection.execute("SET airbyte_warehouse = 'AIRBYTE_WAREHOUSE'")
            connection.execute("SET airbyte_database = 'AIRBYTE_DATABASE'")
            connection.execute("SET airbyte_schema = 'AIRBYTE_SCHEMA'")

            # set user password
            connection.execute("SET airbyte_password = 'password'")

            connection.execute("BEGIN")

            # create Airbyte role
            connection.execute("USE ROLE securityadmin")
            connection.execute("CREATE ROLE IF NOT EXISTS identifier($airbyte_role)")
            connection.execute("GRANT ROLE identifier($airbyte_role) TO ROLE SYSADMIN")

            # create Airbyte user
            connection.execute(
                """
                CREATE USER IF NOT EXISTS identifier($airbyte_username)
                PASSWORD = $airbyte_password
                DEFAULT_ROLE = $airbyte_role
                DEFAULT_WAREHOUSE = $airbyte_warehouse
            """
            )

            connection.execute(
                "GRANT ROLE identifier($airbyte_role) TO USER identifier($airbyte_username)"
            )

            # change role to sysadmin for warehouse / database steps
            connection.execute("USE ROLE sysadmin")

            # create Airbyte warehouse
            connection.execute(
                """
                CREATE WAREHOUSE IF NOT EXISTS identifier($airbyte_warehouse)
                WAREHOUSE_SIZE = 'XSMALL'
                WAREHOUSE_TYPE = 'STANDARD'
                AUTO_SUSPEND = 60
                AUTO_RESUME = TRUE
                INITIALLY_SUSPENDED = TRUE
            """
            )

            # create Airbyte database
            connection.execute(
                "CREATE DATABASE IF NOT EXISTS identifier($airbyte_database)"
            )

            # grant Airbyte warehouse access
            connection.execute(
                "GRANT USAGE ON WAREHOUSE identifier($airbyte_warehouse) TO ROLE identifier($airbyte_role)"
            )

            # grant Airbyte database access
            connection.execute(
                "GRANT OWNERSHIP ON DATABASE identifier($airbyte_database) TO ROLE identifier($airbyte_role)"
            )

            connection.execute("COMMIT")

            connection.execute("BEGIN")

            # use the created database
            connection.execute("USE DATABASE identifier($airbyte_database)")

            # create schema for Airbyte data
            connection.execute("CREATE SCHEMA IF NOT EXISTS identifier($airbyte_schema)")

            connection.execute("COMMIT")

            connection.execute("BEGIN")

            # grant Airbyte schema access
            connection.execute(
                "GRANT OWNERSHIP ON SCHEMA identifier($airbyte_schema) TO ROLE identifier($airbyte_role)"
            )

            connection.execute("COMMIT")
            print("all queries executed")
        except Exception as e:
            print(f"An error occurred: {e}")
            connection.execute("ROLLBACK")
        finally:
            connection.close()

def main():
    engine = get_engine()
    execute_queries(engine)
    engine.dispose()

if __name__ == "__main__":
    main()