#!/bin/bash

# === CONFIGURATION ===
SERVER="192.168.18.18"
USER="sa"
PASS="tracy123"
DATABASE="MatrixRFID"
OUTPUT_DIR="$HOME/sql_exports"     # <- Change this to your desired output dir
OUTPUT_FILE="$OUTPUT_DIR/table_names.txt"
QUERY_FILE="$(mktemp)"             # Temp file to hold SQL

# === SQL to Get All Table Names ===
echo "USE $DATABASE;" > "$QUERY_FILE"
echo "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';" >> "$QUERY_FILE"
echo "GO" >> "$QUERY_FILE"

# === Make sure output directory exists ===
mkdir -p "$OUTPUT_DIR"

# === Run the query and clean the output ===
tsql -S "$SERVER" -U "$USER" -P "$PASS" -D "$DATABASE" -i "$QUERY_FILE" 2>/dev/null | \
  sed -n '/TABLE_NAME/,$p' | grep -v "TABLE_NAME" | grep -v "^$" | sed 's/^[ \t]*//' > "$OUTPUT_FILE"

# === Output path info ===
echo "✅ Table names saved to: $OUTPUT_FILE"

# === Clean up ===
rm "$QUERY_FILE"
