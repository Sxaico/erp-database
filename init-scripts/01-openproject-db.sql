-- 01-openproject-db.sql (FIX: siempre setea password)
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', 'openproject_user', 'openproject_password123')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'openproject_user')
\gexec

-- Siempre asegurar password (si el rol ya existía con otra)
ALTER ROLE openproject_user WITH LOGIN PASSWORD 'openproject_password123';

SELECT format('CREATE DATABASE %I OWNER %I', 'openproject_db', 'openproject_user')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'openproject_db')
\gexec

ALTER DATABASE openproject_db OWNER TO openproject_user;
GRANT ALL PRIVILEGES ON DATABASE openproject_db TO openproject_user;

