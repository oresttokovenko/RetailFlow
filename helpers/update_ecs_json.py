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
### dagster dbt containers ###
#############################

import json

container_images = {
    "dagit": f"{account_id}.dkr.ecr.us-west-2.amazonaws.com/dagit_container:latest",
    "daemon": f"{account_id}.dkr.ecr.us-west-2.amazonaws.com/daemon_container:latest",
    "postgresql": f"{account_id}.dkr.ecr.us-west-2.amazonaws.com/dagster_postgresql_container:latest",
    "dbt": f"{account_id}.dkr.ecr.us-west-2.amazonaws.com/dbt_container:latest"
}

# load json file
with open('transformation/dagster_dbt_task_definition.json', 'r') as f:
    task_definition = json.load(f)

# loop over each containerDefinition and update the image
for container in task_definition:
    container_name = container['name']
    if container_name in container_images:
        container['image'] = container_images[container_name]

# write back to the file
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
