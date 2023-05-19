# RetailFlow

## Description

RetailFLow is an end-to-end data engineering project that aims to generate fake retail sales data for an e-commerce store, ingest it into Snowflake using Airbyte, orchestrate and perform the data transformations using Dagster and dbt, and visualize the data using Metabase. This project will be deployed on AWS infrastructure using Terraform.

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