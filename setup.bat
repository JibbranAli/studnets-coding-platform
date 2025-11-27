@echo off
REM Student Code Debugging Platform - Windows Setup Script
REM This script automates the installation and configuration process

setlocal enabledelayedexpansion

echo ==========================================
echo Student Code Debugging Platform Setup
echo ==========================================
echo.

REM Check for Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.11+ from https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [INFO] Python found
python --version
echo.

REM Step 1: Create virtual environment
echo [INFO] Step 1: Creating Python virtual environment...
if exist venv (
    echo [INFO] Virtual environment already exists
) else (
    python -m venv venv
    echo [SUCCESS] Virtual environment created
)
echo.

REM Step 2: Activate virtual environment and install dependencies
echo [INFO] Step 2: Installing Python dependencies...
call venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)
echo [SUCCESS] Dependencies installed
echo.

REM Step 3: Setup environment file
echo [INFO] Step 3: Setting up environment configuration...
if exist .env (
    echo [INFO] .env file already exists, skipping
) else (
    copy .env.example .env
    echo [SUCCESS] Created .env file from template
    echo [INFO] Please edit .env file with your configuration
    
    REM Generate random secret key
    python -c "import secrets; print(secrets.token_urlsafe(32))" > temp_key.txt
    set /p SECRET_KEY=<temp_key.txt
    del temp_key.txt
    
    REM Update .env with generated secret key
    powershell -Command "(Get-Content .env) -replace 'your-secret-key-change-this-in-production', '%SECRET_KEY%' | Set-Content .env"
    echo [SUCCESS] Generated secure SECRET_KEY
)
echo.

REM Step 4: Database selection
echo [INFO] Step 4: Database configuration...
set /p USE_POSTGRES="Do you want to use PostgreSQL? (y/n, default: n - uses SQLite): "
if /i "%USE_POSTGRES%"=="y" (
    set /p DB_NAME="Enter PostgreSQL database name [student_debug_platform]: "
    if "!DB_NAME!"=="" set DB_NAME=student_debug_platform
    
    set /p DB_USER="Enter PostgreSQL username [student_user]: "
    if "!DB_USER!"=="" set DB_USER=student_user
    
    set /p DB_PASSWORD="Enter PostgreSQL password: "
    
    set /p DB_HOST="Enter PostgreSQL host [localhost]: "
    if "!DB_HOST!"=="" set DB_HOST=localhost
    
    set /p DB_PORT="Enter PostgreSQL port [5432]: "
    if "!DB_PORT!"=="" set DB_PORT=5432
    
    set DB_URL=postgresql://!DB_USER!:!DB_PASSWORD!@!DB_HOST!:!DB_PORT!/!DB_NAME!
    powershell -Command "(Get-Content .env) -replace 'DATABASE_URL=.*', 'DATABASE_URL=!DB_URL!' | Set-Content .env"
    echo [SUCCESS] PostgreSQL database configured
) else (
    powershell -Command "(Get-Content .env) -replace 'DATABASE_URL=.*', 'DATABASE_URL=sqlite:///./student_platform.db' | Set-Content .env"
    echo [SUCCESS] SQLite database configured
)
echo.

REM Step 5: Initialize database
echo [INFO] Step 5: Initializing database tables...
python -c "from database import init_db; init_db()"
if errorlevel 1 (
    echo [ERROR] Failed to initialize database
    pause
    exit /b 1
)
echo [SUCCESS] Database initialized
echo.

REM Step 6: Create data directory
echo [INFO] Step 6: Creating data directory...
if not exist data mkdir data
echo [SUCCESS] Data directory created
echo.

REM Step 7: Setup admin credentials
echo [INFO] Step 7: Setting up admin credentials...
set /p ADMIN_USER="Enter admin username [admin]: "
if "%ADMIN_USER%"=="" set ADMIN_USER=admin

set /p ADMIN_PASS="Enter admin password: "
if "%ADMIN_PASS%"=="" set ADMIN_PASS=change_this_secure_password

powershell -Command "(Get-Content .env) -replace 'ADMIN_USERNAME=.*', 'ADMIN_USERNAME=%ADMIN_USER%' | Set-Content .env"
powershell -Command "(Get-Content .env) -replace 'ADMIN_PASSWORD=.*', 'ADMIN_PASSWORD=%ADMIN_PASS%' | Set-Content .env"
echo [SUCCESS] Admin credentials configured
echo.

REM Step 8: Create startup script
echo [INFO] Step 8: Creating startup script...
(
echo @echo off
echo call venv\Scripts\activate.bat
echo streamlit run app.py
) > start.bat
echo [SUCCESS] Created start.bat script
echo.

REM Final summary
echo ==========================================
echo Setup Complete!
echo ==========================================
echo.
echo [SUCCESS] Installation completed successfully!
echo.
echo Next steps:
echo 1. Review and update .env file with your settings
echo 2. Start the application by running: start.bat
echo 3. Access the application at http://localhost:8501
echo.
echo For production deployment, refer to DEPLOYMENT.md
echo.
echo [INFO] Admin credentials:
echo    Username: %ADMIN_USER%
echo    Password: [as configured]
echo.
pause
