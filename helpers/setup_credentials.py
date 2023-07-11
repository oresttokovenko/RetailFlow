def get_user_input():
    snowflake_user = input("Enter Snowflake username: ")
    snowflake_pass = input("Enter Snowflake password: ")
    snowflake_account_id = input("Enter Snowflake account_id: (ex. E9VQG1LF-HBGF7017) ")
    aws_account_id = input("Enter AWS account ID: (ex. 012345678901) ")
    return snowflake_user, snowflake_pass, snowflake_account_id, aws_account_id

def write_to_file(filename, snowflake_user, snowflake_pass, snowflake_account_id, aws_account_id):
    with open(filename, "w") as f:
        f.write(f"SNOWFLAKE_ACCOUNT_ID={snowflake_account_id}\n")
        f.write(f"SNOWFLAKE_PASSWORD={snowflake_pass}\n")
        f.write(f"SNOWFLAKE_USERNAME={snowflake_user}\n")
        if "AWS_ACCOUNT_ID" in filename:
            f.write(f"AWS_ACCOUNT_ID={aws_account_id}\n")
        if "SNOWFLAKE_ROLE" in filename:
            f.write(f"SNOWFLAKE_ROLE={snowflake_user}\n")

def main():
    snowflake_user, snowflake_pass, snowflake_account_id, aws_account_id = get_user_input()
    write_to_file(".env", snowflake_user, snowflake_pass, snowflake_account_id, aws_account_id)
    write_to_file(".transformation/dbt/.env", snowflake_user, snowflake_pass, snowflake_account_id, aws_account_id)

if __name__ == "__main__":
    main()
