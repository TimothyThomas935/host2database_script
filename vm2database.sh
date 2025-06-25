#!/usr/bin/env bash
set -euo pipefail

# ——————— CONFIGURATION ———————
# Path inside the VM to your CSV (update if yours is different)
CSV_FILE="/mnt/shared/db_data/tagassignment_data.csv"

# Supabase project ref (the part before “.supabase.co”)
SUPABASE_REF="zikyldcitoqkbfkipoxe"

# Postgres connection details
DB_HOST="db.${SUPABASE_REF}.supabase.co"
DB_PORT=5432
DB_NAME="postgres"
DB_USER="postgres"

# Supply your password securely via env var:
: "${DB_PASSWORD:?Please export DB_PASSWORD (e.g. export DB_PASSWORD='…')}"
export PGPASSWORD="$DB_PASSWORD"

# Build the connection string (SSL enforced)
PSQL_CONN="postgresql://${DB_USER}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=require"

# ——————— RUN THE UPSERT ———————
psql --set ON_ERROR_STOP=on "$PSQL_CONN" <<EOF
BEGIN;

-- 1) Create a temp staging table matching your real table’s structure
CREATE TEMP TABLE staging (LIKE tagassignment_data INCLUDING ALL);

-- 2) Bulk-load the CSV into staging
\copy staging FROM '$CSV_FILE' CSV HEADER;

-- 3) Merge into the real table on TagID
INSERT INTO tagassignment_data (
    "FirstName",
    "LastName",
    "TagType",
    "TagID",
    "Person",
    "DateTime",
    "TP_IPPort",
    "ReaderName",
    "ReaderDescription"
)
SELECT
    "FirstName",
    "LastName",
    "TagType",
    "TagID",
    "Person",
    "DateTime",
    "TP_IPPort",
    "ReaderName",
    "ReaderDescription"
FROM staging
ON CONFLICT ("TagID") DO UPDATE
  SET
    "FirstName"         = EXCLUDED."FirstName",
    "LastName"          = EXCLUDED."LastName",
    "TagType"           = EXCLUDED."TagType",
    "Person"            = EXCLUDED."Person",
    "DateTime"          = EXCLUDED."DateTime",
    "TP_IPPort"         = EXCLUDED."TP_IPPort",
    "ReaderName"        = EXCLUDED."ReaderName",
    "ReaderDescription" = EXCLUDED."ReaderDescription";

COMMIT;
EOF
