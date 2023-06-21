#!/bin/bash

### this bash script will run inside of an ec2 instance ###
### user = airbyte, pass = password ###

# update and install Docker
sudo yum update -y   
sudo yum install -y docker   
sudo service docker start   
sudo usermod -a -G docker $USER   

# install docker-compose
sudo yum install -y docker-compose-plugin   

# download and run Airbyte's setup script
mkdir airbyte && cd airbyte   
wget https://raw.githubusercontent.com/airbytehq/airbyte/master/run-ab-platform.sh   
chmod +x run-ab-platform.sh  
./run-ab-platform.sh -b
