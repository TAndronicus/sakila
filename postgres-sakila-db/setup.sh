# Postgres
docker run -itd --name sakila-postgres -p 5432:5432 -e POSTGRES_PASSWORD=pass -e POSTGRES_USER=jb -e POSTGRES_DB=sakila postgres:latest
