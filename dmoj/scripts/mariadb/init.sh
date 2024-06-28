sudo mariadb
CREATE DATABASE IF NOT EXISTS "$MYSQL_DATABASE" DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON "$MYSQL_DATABASE".* TO "$MYSQL_USER"@'localhost' IDENTIFIED BY "$MYSQL_PASSWORD";
# shellcheck disable=SC2035 # this is in a mariadb shell so it wont glob
GRANT RELOAD, PROCESS ON *.* TO "$MYSQL_USER"@'%';
FLUSH PRIVILEGES;
exit
mariadb-tzinfo-to-sql /usr/share/zoneinfo | sudo mariadb -u root mysql
