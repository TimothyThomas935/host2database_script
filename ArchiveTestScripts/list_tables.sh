#!/bin/bash

SERVER="192.168.18.18"
USER="sa"
PASS="tracy123"
DB="MatrixRFID"
QUERY_FILE="get_tables.sql"

# Run the query and filter output to just the table names
tsql -S "$SERVER" -U "$USER" -P "$PASS" -D "$DB" -i "$QUERY_FILE" 2>/dev/null | \
  sed -n '/TABLE_NAME/,$p' | grep -v "TABLE_NAME" | grep -v "^$" | sed 's/^[ \t]*//'
