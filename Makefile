####################################################################################################################
# Vars

bold := "\033[1m"
normal := "\033[0m"

TERRAFORM_MAIN := terraform/main
TERRAFORM_LAMBDA := terraform/lambda
LAMBDA_DIR := generate
TAG := ?
ECR_REPO := ?

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

initial_config:
	snowflake_config build-containers

snowflake_config:
	@echo $(bold)"Please complete the following:"$(normal)
	@python helpers/setup.py
	@echo $(bold)"Please wait while the Snowflake setup script runs"$(normal)
	@python storage/snowflake/setup_airbyte_environment.py
	@echo $(bold)"Setup script is complete"$(normal)

build-containers: 
	export $(grep -v '^#' .env | xargs) && \
	aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com
	docker build -t postgres_container -f storage/postgres/Dockerfile .
	docker build -t dbt_dagster_container -f transformation/Dockerfile .
	docker build -t metabase_container -f visualization/Dockerfile .
	docker tag postgres_container:$(TAG) $$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/$(ECR_REPO):$(TAG)
	docker tag dbt_dagster_container:$(TAG) $$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/$(ECR_REPO):$(TAG)
	docker tag metabase_container:$(TAG) $$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/$(ECR_REPO):$(TAG)
	docker push $$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/$(ECR_REPO):$(TAG)
	docker push $$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/$(ECR_REPO):$(TAG)
	docker push $$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/$(ECR_REPO):$(TAG)

infra-up: ## Set up all cloud infrastructure
	ec2 lambda airbyte_run_command

airbyte_run_command:
	@chmod +x ingestion/airbyte/run_airbyte.sh

ec2:
	@cd $(TERRAFORM_MAIN) && \
	terraform init && \
	terraform apply -auto-approve
	@echo $(bold)"EC2 instances created"$(normal)

lambda:
	@echo $(bold)"Generating Lambda package..."$(normal)
	@mkdir -p $(LAMBDA_DIR)/package && \
	pip install -q -r $(LAMBDA_DIR)/requirements.txt -t $(LAMBDA_DIR)/package/ && \
	cp .env_lambda $(LAMBDA_DIR)/package/ && \
	cp $(LAMBDA_DIR)/generate_fake_data.py $(LAMBDA_DIR)/package/ && \
	cd $(LAMBDA_DIR)/package/ && \
	zip -r ../lambda.zip .
	@echo $(bold)"Lambda package created"$(normal)

	@cd $(TERRAFORM_LAMBDA) && \
	terraform init && \
	terraform apply -auto-approve
	@echo $(bold)"Lambda function created"$(normal)

infra-down: ## Destroy all cloud infrastructure
	@rm -rf $(LAMBDA_DIR)/package $(LAMBDA_DIR)/lambda.zip
	@cd $(TERRAFORM_MAIN) && terraform destroy -auto-approve
	@cd $(LAMBDA_DIR) && terraform destroy -auto-approve

####################################################################################################################
# Port forwarding to local machine

# NOTE: the export $(grep -v '^#' .env | xargs) command is used to extract variable assignments from the .env file and export them as environment variables

port-forwarding-metabase: ## Access the Metabase GUI through your local browswer
	export $(grep -v '^#' .env | xargs) && ssh -i "terraform/tf_key.pem" -L 3000:localhost:3000 ec2-user@$$METABASE_EC2_IP_ADDRESS
	open http://localhost:3000

port-forwarding-dagster: ## Access the Dagster GUI through your local browswer
	export $(grep -v '^#' .env | xargs) && ssh -i "terraform/tf_key.pem" -L 3000:localhost:3001 ec2-user@$$DBT_DAGSTER_EC2_IP_ADDRESS
	open http://localhost:3001

open-snowflake: ## Access the Snowflake GUI through your local browswer
	open https://app.snowflake.com

port-forwarding-airbyte: ## Access the Airbyte GUI through your local browswer
	export $(grep -v '^#' .env | xargs) && ssh -i "terraform/tf_key.pem" -L 8000:localhost:8000 ec2-user@$$DBT_DAGSTER_EC2_IP_ADDRESS
	open http://localhost:8000

port-forwarding-dbt: ## Access the Snowflake GUI through your local browswer
	export $(grep -v '^#' .env | xargs) && ssh -i "terraform/tf_key.pem" -L 8080:localhost:8080 ec2-user@$$DBT_DAGSTER_EC2_IP_ADDRESS
	open http://localhost:8080
	# dbt docs generate

print-lambda: ## Fetch the configuration details of the AWS Lambda function
	aws lambda get-function --function-name generate_fake_data.py

####################################################################################################################
# Helpers

# NOTE: the export $(grep -v '^#' .env | xargs) command is used to extract variable assignments from the .env file and export them as environment variables

create-dbt-file: ## Create a ~/.dbt file
	mkdir -p ~/.dbt && touch ~/.dbt/profiles.yml

ssh-ec2-postgres: ## Connect to the EC2 instance running PostgreSQL through SSH
	export $(grep -v '^#' .env | xargs) && ssh -i "terraform/tf_key.pem" ec2-user@$$POSTGRES_EC2_IP_ADDRESS
	@echo $(bold)"SSH Tunnel created"$(normal)

ssh-ec2-dbt-dagster: ## Connect to the EC2 instance running dbt and Dagster through SSH
	export $(grep -v '^#' .env | xargs) && ssh -i "terraform/tf_key.pem" ec2-user@$$DBT_DAGSTER_EC2_IP_ADDRESS
	@echo $(bold)"SSH Tunnel created"$(normal)

ssh-ec2-airbyte: ## Connect to the EC2 instance running Airbyte through SSH
	export $(grep -v '^#' .env | xargs) && ssh -i "terraform/tf_key.pem" ec2-user@$$AIRBYTE_EC2_IP_ADDRESS
	@echo $(bold)"SSH Tunnel created"$(normal)

ssh-ec2-metabase: ## Connect to the EC2 instance running Metabase through SSH
	export $(grep -v '^#' .env | xargs) && ssh -i "terraform/tf_key.pem" ec2-user@$$METABASE_EC2_IP_ADDRESS
	@echo $(bold)"SSH Tunnel created"$(normal)

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