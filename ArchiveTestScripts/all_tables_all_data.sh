#!/bin/bash

OUTPUT_DIR="$HOME/sql_exports/all_tables"
mkdir -p "$OUTPUT_DIR"

echo "🔄 Exporting top 5 rows for each table in MatrixRFID..."

# Get list of tables (cleaned)
TABLES=$(echo -e "USE MatrixRFID\nGO\nSET NOCOUNT ON\nSELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'\nGO\nQUIT" | \
tsql -S METSServer -U sa -P tracy123 -t, 2>/dev/null | \
grep -vE 'locale|charset|rows affected|^[[:space:]]*[0-9]>|^$|^TABLE_NAME' | sed 's/^[ \t]*//;s/[ \t]*$//')

echo "📋 Found tables:"
echo "$TABLES"

for TABLE in $TABLES; do
  echo "📤 Exporting $TABLE..."

  OUTPUT_FILE="$OUTPUT_DIR/${TABLE}_top5.csv"

  # Get column headers and write as CSV header
  echo -e "USE MatrixRFID\nGO\nSET NOCOUNT ON\nSELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='$TABLE'\nGO\nQUIT" | \
  tsql -S METSServer -U sa -P tracy123 -t, 2>/dev/null | \
  grep -vE 'locale|charset|rows affected|^[[:space:]]*[0-9]>|^$|^COLUMN_NAME' | \
  sed 's/^[ \t]*//;s/[ \t]*$//' | paste -sd "," - > "$OUTPUT_FILE"

  # Get top 5 rows and append to file
  echo -e "USE MatrixRFID\nGO\nSET NOCOUNT ON\nSELECT * FROM [$TABLE]\nGO\nQUIT" | \
  tsql -S METSServer -U sa -P tracy123 -t, 2>/dev/null | \
  grep -vE 'locale|charset|rows affected|^[[:space:]]*[0-9]>|^$' | \
  sed 's/^[ \t]*//;s/[ \t]*$//' >> "$OUTPUT_FILE"
done

echo "✅ Export complete! CSV files are in $OUTPUT_DIR"
