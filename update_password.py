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
    print("数据库连接成功！")
    
    with connection.cursor() as cursor:
        # 直接将密码更新为明文（仅用于临时测试！）
        # 注意：生产环境必须使用BCrypt哈希
        # 这里我们创建一个新的测试用户，密码是test123
        sql = """
        INSERT INTO user (username, password, nickname, email) 
        VALUES ('test', 'test123', '测试用户', 'test@example.com')
        ON DUPLICATE KEY UPDATE password='test123'
        """
        cursor.execute(sql)
        connection.commit()
        print("测试用户已创建！用户名: test, 密码: test123")
    
    connection.close()
    print("完成！")
    
except pymysql.Error as e:
    print(f"数据库错误: {e}")
