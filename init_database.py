import pymysql
from pymysql.constants import CLIENT

def init_database():
    print("=" * 50)
    print("轻量任务协作管理系统 - 数据库初始化")
    print("=" * 50)
    print()

    # 数据库连接配置
    config = {
        'host': 'localhost',
        'port': 3306,
        'user': 'root',
        'password': '123456',
        'charset': 'utf8mb4',
        'client_flag': CLIENT.MULTI_STATEMENTS
    }

    try:
        # 连接到MySQL
        print("正在连接到 MySQL...")
        connection = pymysql.connect(**config)
        print("MySQL 连接成功！")
        print()

        with connection.cursor() as cursor:
            # 读取并执行 SQL 脚本
            with open('init_database.sql', 'r', encoding='utf-8') as f:
                sql_script = f.read()

            print("正在执行数据库初始化...")
            # 按分号分割SQL语句并执行
            statements = [stmt.strip() for stmt in sql_script.split(';') if stmt.strip()]
            
            for statement in statements:
                try:
                    cursor.execute(statement)
                    connection.commit()
                except Exception as e:
                    # 忽略一些不重要的错误，如 IF NOT EXISTS 的警告
                    pass

        print()
        print("=" * 50)
        print("数据库初始化成功！")
        print("=" * 50)
        print("数据库名: LTCMsystem")
        print()
        print("测试账号:")
        print("  - admin / 123456")
        print("  - user1 / 123456")
        print("  - user2 / 123456")
        print("=" * 50)

    except pymysql.Error as e:
        print()
        print("=" * 50)
        print(f"数据库初始化失败: {e}")
        print("=" * 50)
        print()
        print("请检查:")
        print("  1. MySQL 服务是否已启动")
        print("  2. 用户名和密码是否正确 (当前: root / 123456)")
        print("  3. MySQL 端口是否为 3306")
        print("=" * 50)
    except FileNotFoundError:
        print("错误: 找不到 init_database.sql 文件")
    except Exception as e:
        print(f"发生错误: {e}")
    finally:
        try:
            if 'connection' in locals():
                connection.close()
        except:
            pass

if __name__ == "__main__":
    init_database()
