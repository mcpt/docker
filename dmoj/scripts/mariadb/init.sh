#!/bin/bash

# Create SQL command with expanded variables (note the backticks for command substitution)
SQL="
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT RELOAD, PROCESS ON *.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
exit
"

# Execute SQL command in MariaDB
mariadb --user=root --password="${MYSQL_ROOT_PASSWORD}" -e "$SQL"
