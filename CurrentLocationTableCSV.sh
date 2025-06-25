#!/usr/bin/env bash
set -euo pipefail

# Path to your CSV inside the VM
CSV_FILE="/mnt/shared/db_data/tagassignment_data.csv"

# Full Session-pooler URI with your new inline service_role key
CONN="postgresql://postgres.zikyldcitoqkbfkipoxe:hvO1q+txUYdpT+HVu+nDm6OGepRUgA1nCrdk7XmUb50xXq0HtUml0GJ3fGQrM8hcAj4CMW+0wkmAW0jrwe7VPg==@aws-0-us-east-1.pooler.supabase.com:5432/postgres?sslmode=require"

# Run the import/merge
psql --set ON_ERROR_STOP=on "$CONN" <<EOF
BEGIN;
  -- Create a staging table matching your real one
  CREATE TEMP TABLE staging (LIKE tagassignment_data INCLUDING ALL);

  -- Bulk-load your CSV into staging
  \copy staging FROM '$CSV_FILE' CSV HEADER;

  -- Upsert into your real table on TagID
  INSERT INTO tagassignment_data
    SELECT * FROM staging
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

echo "✅ Import complete"

