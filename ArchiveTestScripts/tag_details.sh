#!/bin/bash

OUTPUT_DIR="$HOME/sql_exports"
OUTPUT_FILE="$OUTPUT_DIR/tagdetails_top5.csv"

mkdir -p "$OUTPUT_DIR"

# 1. Get column names and write as CSV header
echo "USE MatrixRFID
GO
SET NOCOUNT ON
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TagDetails'
GO
QUIT" | tsql -S METSServer -U sa -P tracy123 -t, 2>/dev/null | \
grep -vE 'locale|rows affected|^[[:space:]]*[0-9]>|^$|^COLUMN_NAME' | \
sed 's/^[ \t]*//;s/[ \t]*$//' | paste -sd "," - > "$OUTPUT_FILE"

# 2. Get top 5 rows and append to CSV
echo "USE MatrixRFID
GO
SET NOCOUNT ON
SELECT TOP 5 * FROM TagDetails
GO
QUIT" | tsql -S METSServer -U sa -P tracy123 -t, 2>/dev/null | \
grep -vE 'locale|rows affected|^[[:space:]]*[0-9]>|^$' | \
sed 's/^[ \t]*//;s/[ \t]*$//' >> "$OUTPUT_FILE"

echo "✅ CSV with headers and top 5 rows written to: $OUTPUT_FILE"
