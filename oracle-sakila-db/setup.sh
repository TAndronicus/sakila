bash oracle/buildDockerImage.sh -v 19.3.0 -e
docker run -itd --name sakila-oracle -p 1521:1521 -p 5500:5500 -e ORACLE_SID=sakila -e ORACLE_PDB=nsakila -v /home/jb/Workspace/JVM/hibernate-mappings/src/main/resources/oracle/19.3.0/custom_scripts:/opt/oracle/scripts/setup oracle/database:19.3.0-ee
