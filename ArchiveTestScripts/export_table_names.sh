#!/bin/bash

# Config
SERVER="METSServer"
USER="sa"
PASS="tracy123"
DATABASE="MatrixRFID"
OUTPUT_DIR="$HOME/sql_exports"
OUTPUT_FILE="$OUTPUT_DIR/table_names.txt"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Run query and clean output
echo "USE $DATABASE
SET NOCOUNT ON
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'
GO
QUIT" | tsql -S "$SERVER" -U "$USER" -P "$PASS" 2>/dev/null | \
awk '/^TABLE_NAME/,/^[[:space:]]*$/' | grep -v "TABLE_NAME" | grep -v 'rows affected' | sed 's/^[ \t]*//;s/[ \t]*$//' > "$OUTPUT_FILE"

echo "✅ Table names exported to: $OUTPUT_FILE"
