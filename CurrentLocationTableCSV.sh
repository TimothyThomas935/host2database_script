#!/bin/bash

OUTPUT_DIR="$HOME/shared/db_data"
mkdir -p "$OUTPUT_DIR"

echo "Exporting TagAssignment data..."

OUTPUT_FILE="$OUTPUT_DIR/tagassignment_data.csv"

SQL_QUERY="
USE MatrixRFID
GO
SET NOCOUNT ON
SELECT 
    QUOTENAME(td.FirstName, '\"') AS FirstName, 
    QUOTENAME(td.LastName, '\"') AS LastName, 
    td.TagType, 
    td.TagID, 
    td.Person, 
    cl.DateTime, 
    QUOTENAME(cl.TP_IPPort, '\"') AS TP_IPPort,
    QUOTENAME(r.Name, '\"') AS ReaderName,
    QUOTENAME(r.Description, '\"') AS ReaderDescription
FROM TagDetails td
LEFT JOIN CurrentLocation cl ON td.TagID = cl.TagID
LEFT JOIN (
    SELECT IPPort, NewAntennaSerialNumber, Name, Description, 
           ROW_NUMBER() OVER (PARTITION BY IPPort, NewAntennaSerialNumber ORDER BY id) AS rn
    FROM Readers
) r ON cl.TP_IPPort = r.IPPort 
    AND cl.NewAntennaSerialNumber = r.NewAntennaSerialNumber 
    AND r.rn = 1
WHERE td.Person = 1
GO
QUIT
"

# Write headers
echo "FirstName,LastName,TagType,TagID,Person,DateTime,TP_IPPort,ReaderName,ReaderDescription" > "$OUTPUT_FILE"

# Get data
echo "$SQL_QUERY" | tsql -S METSServer -U sa -P tracy123 -t, 2>/dev/null | \
grep -vE 'locale|charset|rows affected|^[[:space:]]*[0-9]>|^$' | \
sed 's/^[ \t]*//;s/[ \t]*$//' >> "$OUTPUT_FILE"

echo "Done! CSV file is at $OUTPUT_FILE"