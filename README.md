# RetailFlow

## Description

RetailFLow is an end-to-end ELT data engineering project that aims to generate fake retail sales data for an e-commerce store, ingest it into Snowflake using Airbyte, orchestrate and perform the data transformations using Dagster and dbt, and visualize the data using Metabase. This project will be deployed on AWS infrastructure using Terraform and Docker.

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

## Additional Tasks

- Collect Airbyte logs in CloudWatch
- Add Linting with sqlfluff