# RetailFlow

## Description

RetailFLow is an end-to-end ELT data engineering project that aims to generate fake retail sales data for an e-commerce store, ingest it into Snowflake using Airbyte, orchestrate and perform the data transformations using Dagster and dbt, and visualize the data using Metabase. This project will be deployed on AWS infrastructure using Terraform.

## Data Infrastructure

```mermaid
graph LR
  L["AWS Lambda"]
  subgraph EC2_1["EC2 Instance"]
  P["Postgres DB"]
  end
  subgraph EC2_2["EC2 Instance"]
  A["Airbyte"]
  end
  subgraph EC2_5["Hosted on AWS"]
  S["Snowflake"]
  end
  subgraph EC2_3["EC2 Instance"]
  D["dbt + Airbyte"]
  end
  subgraph EC2_4["EC2 Instance"]
  M["Metabase"]
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
├── INSTRUCTIONS.md
├── LICENSE
├── Makefile
├── README.md
├── assets
│   └── images
│       ├── infra.png
│       ├── proj_1.png
│       └── proj_2.png
├── containers
│   └── airflow
│       ├── Dockerfile
│       └── requirements.txt
├── dags
├── docker-compose.yml
├── env
├── migrations
│   └── temp.py
├── terraform
│   ├── main.tf
│   ├── output.tf
│   └── variable.tf
└── tests
    └── dags
        └── test_dag_validity.py
```

## Additional Tasks

- Collect Airbyte logs in CloudWatch
- Add Linting with sqlfluff