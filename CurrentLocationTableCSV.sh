#!/bin/bash
set -euo pipefail

# ┌──────────────────────────────────────────────────────────┐
# │ Shared output directory for all CSVs                    │
# └──────────────────────────────────────────────────────────┘
OUTPUT_DIR="$HOME/shared/db_data"
mkdir -p "$OUTPUT_DIR"

# ┌──────────────────────────────────────────────────────────┐
# │ 1) Export TagAssignment / CurrentLocation CSV           │
# └──────────────────────────────────────────────────────────┘
echo "Exporting TagAssignment (curr_location_data.csv)..."

OUTPUT_FILE="$OUTPUT_DIR/CurrTagLocation.csv"

# Write header for TagAssignment export
echo "FirstName,LastName,TagType,TagID,Person,DateTime,TP_IPPort,ReaderName,ReaderDescription" > "$OUTPUT_FILE"

# Run your existing tsql query and append to OUTPUT_FILE
SQL_QUERY="
USE MatrixRFID
GO
SET NOCOUNT ON
SELECT 
    QUOTENAME(td.FirstName, '\"') AS FirstName, 
    QUOTENAME(td.LastName,  '\"') AS LastName, 
    td.TagType, 
    td.TagID, 
    td.Person, 
    cl.DateTime, 
    QUOTENAME(cl.TP_IPPort, '\"')        AS TP_IPPort,
    QUOTENAME(r.Name,               '\"') AS ReaderName,
    QUOTENAME(r.Description,        '\"') AS ReaderDescription
FROM TagDetails td
LEFT JOIN CurrentLocation cl 
  ON td.TagID = cl.TagID
LEFT JOIN (
    SELECT IPPort,
           NewAntennaSerialNumber,
           Name,
           Description,
           ROW_NUMBER() OVER (
             PARTITION BY IPPort,NewAntennaSerialNumber 
             ORDER BY id
           ) AS rn
    FROM Readers
) r 
  ON cl.TP_IPPort              = r.IPPort 
 AND cl.NewAntennaSerialNumber = r.NewAntennaSerialNumber 
 AND r.rn = 1
WHERE td.Person = 1
GO
QUIT
"

echo "$SQL_QUERY" | tsql -S METSServer -U sa -P tracy123 -t, 2>/dev/null | \
  grep -vE 'locale|charset|rows affected|^[[:space:]]*[0-9]>|^$' | \
  sed 's/^[ \t]*//;s/[ \t]*$//' >> "$OUTPUT_FILE"

echo "✅ TagAssignment export complete (at $OUTPUT_FILE)"

########################################
# 2) Export HistoryByTag CSV
########################################
echo "Exporting HistoryByTag (HistoryByTag.csv)..."
HISTORY_FILE="$OUTPUT_DIR/HistoryByTag.csv"

# Header for HistoryByTag export (from your table schema)
echo "id,TagID,Computer,IPPort,ReaderChannel,RSSI,DateTime,Counter,FW_Version,LQI,PreAlarm,SequenceNo,SaveReason,PacketType,NewAntennaSerialNumber,TimeBias,FirstSeen,Alarm,TP_IPPort,TP_Partner,TP_Battery,TP_PartnerStr" > "$HISTORY_FILE"

# Query to pull all columns from HistoryByTag
SQL_QUERY2="
USE MatrixRFID
GO
SET NOCOUNT ON
SELECT 
    id,
    TagID,
    Computer,
    IPPort,
    ReaderChannel,
    RSSI,
    DateTime,
    Counter,
    FW_Version,
    LQI,
    PreAlarm,
    SequenceNo,
    SaveReason,
    PacketType,
    NewAntennaSerialNumber,
    TimeBias,
    FirstSeen,
    Alarm,
    TP_IPPort,
    TP_Partner,
    TP_Battery,
    TP_PartnerStr
  FROM HistoryByTag
GO
QUIT
"

echo "$SQL_QUERY2" | tsql -S METSServer -U sa -P tracy123 -t, 2>/dev/null | \
  grep -vE 'locale|charset|rows affected|^[[:space:]]*[0-9]>|^$' | \
  sed 's/^[ \t]*//;s/[ \t]*$//' >> "$HISTORY_FILE"

echo "✅ HistoryByTag export complete (at $HISTORY_FILE)"