import pymysql

# 数据库连接配置
config = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': '123456',
    'database': 'LTCMsystem',
    'charset': 'utf8mb4'
}

try:
    connection = pymysql.connect(**config)
    print("Database connected successfully!")
    
    with connection.cursor() as cursor:
        # 先检查字段是否已存在
        cursor.execute("DESCRIBE team_member")
        columns = [col[0] for col in cursor.fetchall()]
        print(f"Current columns: {columns}")
        
        # 添加 create_time 字段（如果不存在）
        if 'create_time' not in columns:
            print("Adding create_time column...")
            cursor.execute("ALTER TABLE team_member ADD COLUMN create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
            connection.commit()
            print("create_time column added!")
        
        # 添加 update_time 字段（如果不存在）
        if 'update_time' not in columns:
            print("Adding update_time column...")
            cursor.execute("ALTER TABLE team_member ADD COLUMN update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
            connection.commit()
            print("update_time column added!")
        
        # 验证修复结果
        cursor.execute("DESCRIBE team_member")
        print("\nFinal team_member table structure:")
        final_columns = cursor.fetchall()
        for col in final_columns:
            print(f"  - {col[0]}: {col[1]}")
    
    connection.close()
    print("\nDatabase fixed successfully!")
    
except pymysql.Error as e:
    print(f"Database error: {e}")
