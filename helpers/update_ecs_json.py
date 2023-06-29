import json
import os
from dotenv import load_dotenv

load_dotenv()

# fetch account_id
account_id = os.getenv('AWS_ACCOUNT_ID')

##########################
### postgres container ###
##########################

with open('storage/postgres/postgres_db_task_definition.json', 'r') as f:
    task_definition = json.load(f)

task_definition['containerDefinitions'][0]['image'] = f"{account_id}.dkr.ecr.us-west-2.amazonaws.com/postgres_container:latest"

with open('storage/postgres/postgres_db_task_definition.json', 'w') as f:
    json.dump(task_definition, f, indent=2)

#############################
### dagster dbt container ###
#############################

with open('transformation/dagster_dbt_task_definition.json', 'r') as f:
    task_definition = json.load(f)

task_definition['containerDefinitions'][0]['image'] = f"{account_id}.dkr.ecr.us-west-2.amazonaws.com/dbt_dagster_container:latest"

with open('transformation/dagster_dbt_task_definition.json', 'w') as f:
    json.dump(task_definition, f, indent=2)

##########################
### metabase container ###
##########################

with open('visualization/Dockerfile', 'r') as f:
    task_definition = json.load(f)

task_definition['containerDefinitions'][0]['image'] = f"{account_id}.dkr.ecr.us-west-2.amazonaws.com/metabase_container:latest"

with open('visualization/Dockerfile', 'w') as f:
    json.dump(task_definition, f, indent=2)
