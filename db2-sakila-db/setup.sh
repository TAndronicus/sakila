# db2
docker run -itd --name sakila-db2 --privileged=true -p 50000:50000 -e LICENSE=accept -e DB2INSTANCE=jb -e DB2INST1_PASSWORD=pass -e DBNAME=sakila ibmcom/db2
# URL-only, jdbc:db2://localhost:50000/sakila
