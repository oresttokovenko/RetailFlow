# RetailFlow

## Description

RetailFlow is a comprehensive ELT (Extract, Load, Transform) project designed to simulate the flow of retail sales data for an e-commerce platform. The infrastructure is provisioned and managed on AWS, with each service optimized for its specific role in the pipeline.

The data simulation is handled by a Python script executing within an AWS Lambda function. The generated data is then pushed to a PostgreSQL database instance deployed on AWS EC2.

Data is ingested using Airbyte into the data warehousing solution, Snowflake. Airbyte operates on its own EC2 instance, ensuring dedicated resources for the critical task of data synchronization.

For the transformation phase, we utilize a combination of Dagster and dbt, two cutting-edge tools in the data engineering ecosystem. These tools are deployed on an EC2 instance, allowing for a flexible and powerful transformation process.

The final piece of the pipeline is data visualization, which is handled by Metabase. Running on a dedicated EC2 instance, Metabase provides intuitive and insightful data analytics, allowing stakeholders to extract meaningful conclusions from the data.

The entire system is orchestrated using Terraform, an Infrastructure as Code (IaC) tool that simplifies and standardizes infrastructure deployment. On the application level, we utilize Docker for containerization, ensuring consistency across all stages of development and production. Finally, the orchestration of our Docker containers across multiple EC2 instances is managed by AWS ECS (Elastic Container Service), providing a robust, scalable, and efficient solution to our multi-container deployment needs.

## Data Infrastructure

```mermaid
graph LR
  subgraph L["AWS Lambda"]
    style L fill:#e8fce8
    LA["generate_fake_data.py"]
  end
  subgraph EC2_1["EC2 Instance"]
    subgraph D1["Docker"]
      style D1 fill:#d4ebf2
      P["Postgres DB"]
    end
  end
  subgraph EC2_2["EC2 Instance"]
    subgraph D2["Docker"]
      style D2 fill:#d4ebf2
      A["Airbyte"]
    end
  end
  subgraph EC2_5["Hosted on AWS"]
      S["Snowflake"]
  end
  subgraph EC2_3["EC2 Instance"]
    subgraph D3["Docker"]
      style D3 fill:#d4ebf2
      D["dbt +  Dagster"]
    end
  end
  subgraph EC2_4["EC2 Instance"]
    subgraph D4["Docker"]
      style D4 fill:#d4ebf2
      M["Metabase"]
    end
  end
  L -- "Generates Fake Data" --> P
  P -- "Data Ingestion" --> A
  A -- "Data Loading" --> S
  S -- "Data Transformation" --> D
  D -- "Data Transformation" --> S
  S -- "Data Visualization" --> M


linkStyle 0 stroke:#2ecd71,stroke-width:2px;
linkStyle 1 stroke:#2ecd71,stroke-width:2px;
linkStyle 2 stroke:#2ecd71,stroke-width:2px;
linkStyle 3 stroke:#2ecd71,stroke-width:2px;
linkStyle 4 stroke:#2ecd71,stroke-width:2px;
linkStyle 5 stroke:#2ecd71,stroke-width:2px;
```

<br>

## Project Structure

```
.
├── Makefile
├── README.md
├── assets
│   └── images
├── docker-compose.yml
├── generate
│   └── generate_fake_data.py
├── ingestion
│   └── airbyte
├── retailflow_venv
├── storage
│   ├── postgres
│   └── snowflake
├── terraform
│   ├── compute.tf
│   ├── db.tf
│   └── variables.tf
├── transformation
│   ├── dagster
│   ├── dbt
│   └── dockerfile
└── visualization
    └── dockerfile
```

## Requirements

1. AWS Account
2. AWS CLI (installed and configured)
3. Docker
4. Terraform

You can install these requirements using the following command: `brew install docker awscli terraform`

## Set Up

```shell
# Local run & test
make infra-up-local # start the docker containers on your computer

# Create AWS services with Terraform and AWS ECS
make tf-init # Only needed on your first terraform run (or if you add new providers)
make infra-up # type in yes after verifying the changes TF will make

# Wait until the EC2 instance is initialized, you can check this via your AWS UI
# See "Status Check" on the EC2 console, it should be "2/2 checks passed" before proceeding

make cloud-postgres # this command will forward Postgres port from EC2 to your machine and opens pgadmin in the browser
# the user name and password are both admin

make cloud-dagster # this command will forward Airflow port from EC2 to your machine and opens it in the browser
# the user name and password are both admin

make cloud-metabase # this command will forward Metabase port from EC2 to your machine and opens it in the browser
# the user name and password are both admin

make cloud-dbt # this command will forward dbt port from EC2 to your machine and opens it in the browser
# the user name and password are both admin
```

## Tear Down

After you are done, make sure to destroy your cloud infrastructure.

```shell
make infra-down-local # Stop docker containers on your computer
make infra-down # type in yes after verifying the changes TF will make
```