# import pandas as pd
# import pymssql
# from datetime import datetime

# try:
#     conn = pymssql.connect(
#         server='192.168.18.18:1433',
#         database='MatrixRFID',
#         user='sa',
#         password='tracy123',
#         timeout=60
#     )
#     query = pd.read_sql_query(
#         '''
#         SELECT TABLE_NAME 
#         FROM INFORMATION_SCHEMA.TABLES 
#         WHERE TABLE_TYPE = 'BASE TABLE'
#         ''',
#         conn
#     )
#     DF = pd.DataFrame(query)
#     filename = datetime.now().strftime("%Y-%m-%d_%I-%M-%S_%p") + '-QUERY.csv'
#     DF.to_csv(filename, index=False)
#     print(f"Saved to {filename}")
# except Exception as e:
#     print(f"Error: {e}")
# finally:
#     if 'conn' in locals():
#         conn.close()

import pymssql

# Replace these with your actual server info
server = '192.168.18.18'  # or 'SERVERNAME'
user = 'sa'
password = 'tracy123'
database = 'MatrixRFID'

# Connect to SQL Server
conn = pymssql.connect(server, user, password, database)
cursor = conn.cursor()

# Execute a query
cursor.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'")

# Fetch all results
rows = cursor.fetchall()
for row in rows:
    print(row)

# Clean up
conn.close()
