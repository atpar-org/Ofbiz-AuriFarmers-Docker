This the docker compose for runnning the ofbix eth postgres database and ACM entire project with database.

steps to run this project.

1. create the required dir for volumes of data:

mkdir -p ./data/acm-db-data/mysql
mkdir -p ./data/acm-db-data/postgres
mkdir -p ./data/acm-db-data/postgres-replica
mkdir -p ./data/acm-content


2. set the correct permissions:

sudo chown -R 999:999 ./data/acm-db-data/mysql   # MySQL user
sudo chown -R 70:70 ./data/acm-db-data/postgres  # PostgreSQL user
sudo chown -R 999:999 ./data/acm-content         # Content storage


3. Run the docker compose up 

docker compose -f ofbiz-acm-compose.yml up

4. run the compose in detach mode

docker compose -f ofbiz-acm-compose.yml up -d
