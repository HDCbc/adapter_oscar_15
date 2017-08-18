#!/bin/bash
set -e

# Create the two databases that data will be restored into.
mysql -u root --password="$MYSQL_ROOT_PASSWORD" <<-EOSQL
  SET GLOBAL FOREIGN_KEY_CHECKS=0;
  CREATE DATABASE oscar;
  CREATE DATABASE drugref;
EOSQL

# Restore the Oscar database
mysql -u root --password="$MYSQL_ROOT_PASSWORD" -D oscar < ./sql/oscar_backup.sql

# Restore the DrugRef database
mysql -u root --password="$MYSQL_ROOT_PASSWORD" -D drugref < ./sql/drugref_backup.sql

# Create the user that the adapter will use to extract data.
mysql -u root --password="$MYSQL_ROOT_PASSWORD" <<-EOSQL
  CREATE USER 'hdc_adapter'@'%' IDENTIFIED BY 'hdc_adapter';
  GRANT ALL PRIVILEGES ON *.* TO 'hdc_adapter'@'%' WITH GRANT OPTION;
EOSQL
