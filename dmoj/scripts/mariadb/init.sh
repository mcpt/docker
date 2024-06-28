sudo mariadb
CREATE DATABASE "$MYSQL_DATABASE" DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON "$MYSQL_DATABASE".* TO "$MYSQL_USER"@'localhost' IDENTIFIED BY "$MYSQL_PASSWORD";
exit
mariadb-tzinfo-to-sql /usr/share/zoneinfo | sudo mariadb -u root mysql
