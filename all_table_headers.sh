#!/bin/bash

OUTPUT_DIR="$HOME/sql_exports"
OUTPUT_FILE="$OUTPUT_DIR/all_table_headers.txt"

mkdir -p "$OUTPUT_DIR"

# Clear output file first
> "$OUTPUT_FILE"

# Query to get all table names and their columns
echo "USE MatrixRFID
GO
SET NOCOUNT ON
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_NAME, ORDINAL_POSITION
GO
QUIT" | tsql -S METSServer -U sa -P tracy123 -t, 2>/dev/null | \
grep -vE 'locale|rows affected|^[[:space:]]*[0-9]>|^$|^TABLE_NAME' | \
sed 's/^[ \t]*//;s/[ \t]*$//' > "$OUTPUT_DIR/tmp_columns_raw.txt"

# Process into grouped format
current_table=""
while IFS=',' read -r table column; do
  if [[ "$table" != "$current_table" ]]; then
    # New table found
    if [[ -n "$current_table" ]]; then
      echo "" >> "$OUTPUT_FILE"  # newline between tables
    fi
    echo "$table" >> "$OUTPUT_FILE"
    current_table="$table"
    header_line="$column"
  else
    header_line="$header_line,$column"
  fi
  next_line=$(grep -A1 "$table,$column" "$OUTPUT_DIR/tmp_columns_raw.txt" | tail -n1)
  if [[ "$next_line" != "$table,"* ]]; then
    echo "$header_line" >> "$OUTPUT_FILE"
  fi
done < "$OUTPUT_DIR/tmp_columns_raw.txt"

rm "$OUTPUT_DIR/tmp_columns_raw.txt"

echo "✅ All table headers written to: $OUTPUT_FILE"
