open('.env_lambda', 'a').close()

snowflake_user = input("Enter Snowflake username: ")
snowflake_pass = input("Enter Snowflake password: ")
snowflake_account_id = input("Enter Snowflake account_id: (ex. E9VQG1LF-HBGF7017) ")
aws_account_id = input("Enter AWS account ID: (ex. 012345678901) ")

with open(".env", "w") as f:
    f.write(f"SNOWFLAKE_ACCOUNT_ID={snowflake_account_id}\n")
    f.write(f"SNOWFLAKE_PASSWORD={snowflake_pass}\n")
    f.write(f"SNOWFLAKE_USERNAME={snowflake_user}\n")
    f.write(f"AWS_ACCOUNT_ID={aws_account_id}\n")

with open(".transformation/dbt/.env", "w") as f:
    f.write(f"SNOWFLAKE_ACCOUNT={snowflake_account_id}\n")
    f.write(f"SNOWFLAKE_PASSWORD={snowflake_pass}\n")
    f.write(f"SNOWFLAKE_USERNAME={snowflake_user}\n")
    f.write(f"SNOWFLAKE_ROLE={snowflake_user}\n")