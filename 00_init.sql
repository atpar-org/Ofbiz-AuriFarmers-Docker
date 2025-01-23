-- Create the OLAP user and database
CREATE USER ofbizolap WITH ENCRYPTED PASSWORD 'ofbizolap';
CREATE DATABASE ofbiz_olap OWNER ofbizolap;
GRANT ALL PRIVILEGES ON DATABASE ofbiz_olap TO ofbizolap;

-- Create the Tenant user and database
CREATE USER ofbiztenant WITH ENCRYPTED PASSWORD 'ofbiztenant';
CREATE DATABASE ofbiztenant OWNER ofbiztenant;
GRANT ALL PRIVILEGES ON DATABASE ofbiztenant TO ofbiztenant;

-- Optional: Grant replication role to the users (if needed)
-- ALTER USER ofbizolap WITH REPLICATION;
-- ALTER USER ofbiztenant WITH REPLICATION;

-- Ensure the primary database user exists
-- CREATE USER ofbiz WITH ENCRYPTED PASSWORD 'ofbiz';
-- CREATE DATABASE ofbiz OWNER ofbiz;
GRANT ALL PRIVILEGES ON DATABASE ofbiz TO ofbiz;

CREATE ROLE atparreplicator WITH REPLICATION LOGIN PASSWORD 'atparreplicator';

SELECT * FROM pg_create_physical_replication_slot('replication_slot');
CREATE ROLE ofbiz LOGIN PASSWORD 'ofbiz';

