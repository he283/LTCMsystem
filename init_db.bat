@echo off
echo ========================================
echo 轻量任务协作管理系统 - 数据库初始化
echo ========================================
echo.
echo 请确保MySQL服务已启动，且root用户密码为123456
echo 如果密码不同，请修改此脚本中的密码
echo.

set MYSQL_USER=root
set MYSQL_PASSWORD=123456
set MYSQL_HOST=localhost
set MYSQL_PORT=3306

echo 正在执行数据库初始化...
mysql -h %MYSQL_HOST% -P %MYSQL_PORT% -u %MYSQL_USER% -p%MYSQL_PASSWORD% < init_database.sql

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo 数据库初始化成功！
    echo ========================================
    echo 数据库名: LTCMsystem
    echo 测试账号:
    echo   - admin / 123456
    echo   - user1 / 123456
    echo   - user2 / 123456
    echo ========================================
) else (
    echo.
    echo ========================================
    echo 数据库初始化失败！
    echo ========================================
    echo 请检查:
    echo   1. MySQL服务是否已启动
    echo   2. 用户名和密码是否正确
    echo   3. MySQL是否在PATH中
    echo ========================================
)
echo.
pause
