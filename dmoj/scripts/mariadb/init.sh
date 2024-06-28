#!/bin/bash

# Load environment variables from environment/mysql.env
set -a
source environment/mysql.env
source environment/mysql-admin.env
set +a

# Create SQL command with expanded variables (note the backticks for command substitution)
SQL="
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT RELOAD, PROCESS ON *.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
exit
"

# Execute SQL command in MariaDB
mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "$SQL"
