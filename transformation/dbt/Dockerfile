FROM python:3.9

# Update and install system packages
RUN apt-get update -y && \
  apt-get install --no-install-recommends -y -q \
  git libpq-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set environment variables
ENV DBT_DIR /dbt

# Set working directory
WORKDIR $DBT_DIR

# Copy requirements
COPY requirements.txt .

# Install dbt
RUN pip install -U pip
RUN pip install -r requirements.txt

# Copy the profiles.yml file to the expected directory
RUN mkdir -p /root/.dbt
COPY profiles.yml /root/.dbt/

# Add dbt_project_1 to the docker image
COPY retailflow_transformation ./dbt_project
RUN ["dbt", "deps", "--project-dir", "./dbt_project"]
