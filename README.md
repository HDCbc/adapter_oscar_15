# Purpose

To extract data from an Oscar 15 MySQL backup file, transform it into the Universal Schema format, and insert the data into an already running instance of a Vault.

# Workings:
When executing the docker-compose commands two containers are instantiated in parallel:
1. The database container is a MYSQL 5.5 database with run time options to speed up the database
   restore and extraction of data. We can be very blunt with these settings as we are not inserting
   any data into this database. The database backup file is then restored into the database which can take
   some time*. After the restore is complete, a user is created and granted full priveleges to the
   newly restored database.
2. The adapter container is a node application. It will try to connect to the database every minute
   for 60 minutes to allow the database appropriate time to restore. Once a connection is established
   the adapter goes through two separate phases.
   1. The adapter extracts all of the necessary data from the MySql database. This is done using the
   new user that was created above. The "necessary data" is described in the mapping file. This file
  is specific to Oscar 15.

# Requirements

Install Docker as per https://docs.docker.com/engine/installation/linux/ubuntu/
Install Docker Compose as per https://docs.docker.com/compose/install/
Install PostgreSQL as per

# Configuration

### Postgres Configuration
Edit the pg_hba file to allow docker containers to connect.
```
$ sudo nano /etc/postgresql/9.5/main/pg_hba.conf
host    all             adapter             172.16.0.0/12           md5
```

Edit the postgresql.conf file to listen
```
$ sudo nano /etc/postgresql/9.5/main/postgresql.conf

Set the following:
listen_addresses = '0.0.0.0'
```

### Firewall Configuration

Firewall must allow connections from Docker containers to connect to the host Postgres.

```sh
$ sudo ufw allow from 172.16.0.0/12 to any port 5432
$ sudo ufw enable
```

### Vault
A Vault (https://github.com/HDCbc/vault) database must be created within Postgres with a user that has full access to the Universal schema and access to create/drop an etl schema. See the init.sh scripts.



# Installation

Clone this git repository
```sh
$ git clone https://github.com/HDCbc/adapter_oscar_15.git
$ cd adapter_oscar_15
```

Edit the configuration variables in the .env file
```sh
$ vi .env
```


# Execution

Start the docker containers. On the first run this will take extra time as all of the images will be downloaded.
```sh
$ sudo docker-compose up
```

# Performance

The amount of time required to extract, transform and load the data from the MySQL backup files into the Vault is highly dependent on the size of the backup files and the specs of the machine. Here are some basic benchmarks:

Intel NUC
2x Dual Core
8 GB Ram

Backup Size: 5GB
Restore: 14 minutes
Adapter: 5 minutes
THIS IS ONLY A PARTIAL MAPPING! Update with the complete mapping!
