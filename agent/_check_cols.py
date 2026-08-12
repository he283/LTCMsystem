import pymysql

conn = pymysql.connect(
    host='localhost', port=3306, user='root', password='123456',
    database='LTCMsystem', charset='utf8mb4'
)
cursor = conn.cursor()
for table in ['user', 'team_member', 'team_role', 'notification']:
    print(f"\n=== {table} ===")
    cursor.execute(f"DESCRIBE {table}")
    for col in cursor.fetchall():
        print(f"  {col[0]:30} {col[1]}")
cursor.close()
conn.close()
