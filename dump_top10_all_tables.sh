#!/bin/bash

OUTPUT_FILE="$HOME/sql_exports/top10_all_tables.txt"
mkdir -p "$(dirname "$OUTPUT_FILE")"
> "$OUTPUT_FILE"  # Clear existing content

echo "🔄 Dumping top 10 rows for each table into: $OUTPUT_FILE"

# Get list of table names, excluding 'Snapshot' and 'WamsImages' and Areas
TABLES=$(echo -e "USE MatrixRFID\nGO\nSET NOCOUNT ON\nSELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'\nGO\nQUIT" | \
tsql -S METSServer -U sa -P tracy123 -t, 2>/dev/null | \
grep -vE 'locale|charset|rows affected|^[[:space:]]*[0-9]>|^$|^TABLE_NAME' | \
sed 's/^[ \t]*//;s/[ \t]*$//' | grep -v -e '^Snapshot$' -e '^WamsImages$' -e '^Areas$')

# Loop through tables
for TABLE in $TABLES; do
  echo "📄 Writing $TABLE..."

  {
    echo ""
    echo "================== $TABLE =================="
    echo ""

    # Column headers
    HEADERS=$(echo -e "USE MatrixRFID\nGO\nSET NOCOUNT ON\nSELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='$TABLE'\nGO\nQUIT" | \
    tsql -S METSServer -U sa -P tracy123 -t, 2>/dev/null | \
    grep -vE 'locale|charset|rows affected|^[[:space:]]*[0-9]>|^$|^COLUMN_NAME' | \
    sed 's/^[ \t]*//;s/[ \t]*$//' | paste -sd "," -)

    echo "$HEADERS"

    # Top 10 rows
    echo -e "USE MatrixRFID\nGO\nSET NOCOUNT ON\nSELECT TOP 100 * FROM [$TABLE]\nGO\nQUIT" | \
    tsql -S METSServer -U sa -P tracy123 -t, 2>/dev/null | \
    grep -vE 'locale|charset|rows affected|^[[:space:]]*[0-9]>|^$' | \
    sed 's/^[ \t]*//;s/[ \t]*$//'
  } >> "$OUTPUT_FILE"

done

echo "✅ Finished. Output written to: $OUTPUT_FILE"
