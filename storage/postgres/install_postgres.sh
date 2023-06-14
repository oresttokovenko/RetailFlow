#!/bin/bash

### this bash script will run inside of an ec2 instance ###

# update system packages
yum update -y

# enable repository to install postgresql
amazon-linux-extras enable postgresql15

# install postgresql server and initalize the database cluster
yum install postgresql-server postgresql-devel -y
/usr/bin/postgresql-setup --initdb

# backup PostgreSQL authentication config file
mv /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.bak

# create our new PostgreSQL authentication config file
cat <<'EOF' > /var/lib/pgsql/data/pg_hba.conf
${pg_hba_file}
EOF

# start the db service
systemctl enable postgresql
systemctl start postgresql