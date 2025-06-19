#!/bin/bash

OUTPUT_DIR="$HOME/sql_exports"
OUTPUT_FILE="$OUTPUT_DIR/table_names.txt"

mkdir -p "$OUTPUT_DIR"

# Run query and clean output
echo "USE MatrixRFID
GO
SET NOCOUNT ON
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'
GO
QUIT" | tsql -S METSServer -U sa -P tracy123 2>/dev/null | \
grep -vE 'locale|using default|rows affected|^[[:space:]]*[0-9]>|^$|^TABLE_NAME' | \
sed 's/^[ \t]*//;s/[ \t]*$//' > "$OUTPUT_FILE"

echo "✅ Table name written to: $OUTPUT_FILE"
