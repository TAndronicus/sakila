# MySQL
docker run -itd --name sakila-mysql -e MYSQL_DATABASE=sakila -e MYSQL_USER=jb -e MYSQL_PASSWORD=pass -e MYSQL_ALLOW_EMPTY_PASSWORD=true -p 3306:3306 mysql
docker exec sakila-mysql bash -c "mysql -u root -e 'set global log_bin_trust_function_creators=true;'"
# MariaDB - TODO
