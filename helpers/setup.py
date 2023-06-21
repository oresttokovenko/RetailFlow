snowflake_user = input("Enter Snowflake username: ")
snowflake_pass = input("Enter Snowflake password: ")
snowflake_account_id = input("Enter Snowflake account_id: ")

with open(".env_test", "w") as f:
    f.write(f"SNOWFLAKE_ACCOUNT_ID={snowflake_account_id}\n")
    f.write(f"SNOWFLAKE_PASSWORD={snowflake_pass}\n")
    f.write(f"SNOWFLAKE_USERNAME={snowflake_user}\n")
