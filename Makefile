####################################################################################################################
# Help

help: ## Print all commands (including this one)
	@python helpers/ascii_graphic.py
	@sleep 2
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	
####################################################################################################################
# Creating a Virtual Environment

setup: ## Create a virtual environment and installs requirements
	create-virtualenv install-requirements

create-virtualenv: 
	@echo "Creating virtual environment with python3.10..."
	test -d retailflow_venv || python3.10 -m venv retailflow_venv

install-requirements:
	@echo "Installing requirements..."
	. retailflow_venv/bin/activate && pip install -r requirements.txt

clean: ## Remove the virtual environment directory
	@echo "Cleaning up virtual environment..."
	rm -rf retailflow_venv

####################################################################################################################
# Deploy the pipeline to the AWS cloud

snowflake_config: ## Set up Snowflake credentials and prepare Snowflake for Airbyte connection
	@echo "Please complete the following:"
	@python helpers/setup.py
	@echo "Please wait while the Snowflake setup script runs"
	@python storage/snowflake/setup_airbyte_environment.py
	@echo "Setup script is complete - you can proceed to run `tf-init`"

tf-init: ## Run `terraform init` - ensure this is run before `infra-up`
	terraform -chdir=./terraform init

infra-up: ## Set up cloud infrastructure
	terraform -chdir=./terraform apply

infra-down: ## Destroy cloud infrastructure
	terraform -chdir=./terraform destroy

infra-config:
	terraform -chdir=./terraform output

####################################################################################################################
# Port forwarding to local machine

cloud-metabase: ## Access the Metabase GUI through your local browswer
	terraform -chdir=./terraform output -raw private_key > private_key.pem && chmod 600 private_key.pem && ssh -o "IdentitiesOnly yes" -i private_key.pem ubuntu@$$(terraform -chdir=./terraform output -raw ec2_public_dns) -N -f -L 3001:$$(terraform -chdir=./terraform output -raw ec2_public_dns):3000 && open http://localhost:3001 && rm private_key.pem

cloud-dagster: ## Access the Dagster GUI through your local browswer
	terraform -chdir=./terraform output -raw private_key > private_key.pem && chmod 600 private_key.pem && ssh -o "IdentitiesOnly yes" -i private_key.pem ubuntu@$$(terraform -chdir=./terraform output -raw ec2_public_dns) -N -f -L 8081:$$(terraform -chdir=./terraform output -raw ec2_public_dns):8080 && open http://localhost:8081 && rm private_key.pem

cloud-snowflake: ## Access the Snowflake GUI through your local browswer
	open https://app.snowflake.com

cloud-airbyte: ## Access the Airbyte GUI through your local browswer
	pass

cloud-dbt: ## Access the Snowflake GUI through your local browswer
	dbt docs generate

print-lambda: ## Fetch the configuration details of the AWS Lambda function
	aws lambda get-function --function-name generate_fake_data.py

####################################################################################################################
# Helpers

create-dbt-file: ## Create a ~/.dbt file
	mkdir -p ~/.dbt && touch ~/.dbt/profiles.yml

ssh-ec2-postgres: ## Connect to the EC2 instance running PostgreSQL through SSH
	export $(grep -v '^#' .env | xargs) && ssh -i "terraform/tf_key.pem" ec2-user@$$POSTGRES_EC2_IP_ADDRESS

ssh-ec2-dbt-dagster: ## Connect to the EC2 instance running dbt and Dagster through SSH
	export $(grep -v '^#' .env | xargs) && ssh -i "terraform/tf_key.pem" ec2-user@$$DBT_DAGSTER_EC2_IP_ADDRESS

ssh-ec2-airbyte: ## Connect to the EC2 instance running Airbyte through SSH
	export $(grep -v '^#' .env | xargs) && ssh -i "terraform/tf_key.pem" ec2-user@$$AIRBYTE_EC2_IP_ADDRESS

ssh-ec2-metabase: ## Connect to the EC2 instance running Metabase through SSH
	export $(grep -v '^#' .env | xargs) && ssh -i "terraform/tf_key.pem" ec2-user@$$METABASE_EC2_IP_ADDRESS

####################################################################################################################
# TODO: Local deployment option using docker-compose

# docker-spin-up: ## Setup containers to run pipeline
# 	docker compose --env-file env up dagster-init && docker compose --env-file env up --build -d

# perms:
# 	sudo mkdir -p logs plugins temp dags tests migrations && sudo chmod -R u=rwx,g=rwx,o=rwx logs plugins temp dags tests migrations

# up: 
# 	perms docker-spin-up warehouse-migration

# down:
# 	docker compose down

# sh:
# 	docker exec -ti webserver bash