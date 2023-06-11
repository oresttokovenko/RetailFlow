####################################################################################################################
# Setup local environment for testing

# creates a virtual environment and installs requirements
setup: 
	create-virtualenv install-requirements

# creates a new virtual environment using Python 3.10
create-virtualenv:
	@echo "Creating virtual environment with python3.10..."
	test -d retailflow_venv || python3.10 -m venv retailflow_venv

# activates the virtual environment and installs the required packages
install-requirements:
	@echo "Installing requirements..."
	. retailflow_venv/bin/activate && pip install -r requirements.txt

# clean: removes the virtual environment directory
clean:
	@echo "Cleaning up virtual environment..."
	rm -rf retailflow_venv

####################################################################################################################
# Setup containers to run pipeline

docker-spin-up:
	docker compose --env-file env up dagster-init && docker compose --env-file env up --build -d

perms:
	sudo mkdir -p logs plugins temp dags tests migrations && sudo chmod -R u=rwx,g=rwx,o=rwx logs plugins temp dags tests migrations

up: 
	perms docker-spin-up warehouse-migration

down:
	docker compose down

sh:
	docker exec -ti webserver bash

####################################################################################################################
# Testing, auto formatting, type checks, & Lint checks

pytest:
	docker exec webserver pytest -p no:warnings -v /opt/dagster/tests

format:
	docker exec webserver python -m black -S --line-length 79 .

isort:
	docker exec webserver isort .

type:
	docker exec webserver mypy --ignore-missing-imports /opt/dagster

lint: 
	docker exec webserver flake8 /opt/airflow/dags

ci: isort format type lint pytest

####################################################################################################################
# Set up cloud infrastructure

tf-init:
	terraform -chdir=./terraform init

infra-up:
	terraform -chdir=./terraform apply

infra-down:
	terraform -chdir=./terraform destroy

infra-config:
	terraform -chdir=./terraform output

####################################################################################################################
# Port forwarding to local machine

cloud-metabase:
	terraform -chdir=./terraform output -raw private_key > private_key.pem && chmod 600 private_key.pem && ssh -o "IdentitiesOnly yes" -i private_key.pem ubuntu@$$(terraform -chdir=./terraform output -raw ec2_public_dns) -N -f -L 3001:$$(terraform -chdir=./terraform output -raw ec2_public_dns):3000 && open http://localhost:3001 && rm private_key.pem

cloud-dagster:
	terraform -chdir=./terraform output -raw private_key > private_key.pem && chmod 600 private_key.pem && ssh -o "IdentitiesOnly yes" -i private_key.pem ubuntu@$$(terraform -chdir=./terraform output -raw ec2_public_dns) -N -f -L 8081:$$(terraform -chdir=./terraform output -raw ec2_public_dns):8080 && open http://localhost:8081 && rm private_key.pem

cloud-snowflake:
	# opens snowflake login window

cloud-postgres:
	opens pgadmin

####################################################################################################################
# Helpers

create_dbt_file:
	mkdir -p ~/.dbt && touch ~/.dbt/profiles.yml

ssh-ec2:
	terraform -chdir=./terraform output -raw private_key > private_key.pem && chmod 600 private_key.pem && ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i private_key.pem ubuntu@$$(terraform -chdir=./terraform output -raw ec2_public_dns) && rm private_key.pem
