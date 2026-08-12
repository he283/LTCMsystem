@echo off
chcp 65001 >nul
echo ================================================
echo   LTCM Agent 助手启动脚本
echo ================================================
echo.

cd /d "%~dp0"

echo [1/3] 检查Python环境...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 未检测到Python，请先安装Python 3.9+
    echo 下载地址：https://www.python.org/downloads/
    pause
    exit /b 1
)
echo ✅ Python已安装
python --version

echo.
echo [2/3] 检查并安装依赖...
if not exist "venv" (
    echo 📦 创建虚拟环境 venv...
    python -m venv venv
    if errorlevel 1 (
        echo ❌ 创建虚拟环境失败
        pause
        exit /b 1
    )
)

call venv\Scripts\activate.bat
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

echo.
echo [3/3] 启动Agent服务...
echo 🤖 Agent 地址：http://localhost:5000
echo 💡 按 Ctrl+C 停止服务
echo.

python app.py

pause
