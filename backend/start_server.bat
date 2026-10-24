@echo off
chcp 65001 >nul
title CareLink AI Health Assistant - Backend Server
color 0B

echo ==============================================================================
echo                 CareLink Digital Healthcare Platform
echo             Course: CSE327 - Software Engineering Project
echo               Feature 2.7: AI Health Assistant Chatbot
echo ==============================================================================
echo.

:: Detect if we are already in backend directory or project root
if exist "%~dp0manage.py" (
    cd /d "%~dp0"
) else (
    cd /d "%~dp0backend"
)

:: Check if virtual environment exists
if exist "venv\Scripts\python.exe" (
    set "PYTHON_EXE=venv\Scripts\python.exe"
    echo [OK] Using virtual environment at: venv
) else (
    where python >nul 2>nul
    if %errorlevel% equ 0 (
        set "PYTHON_EXE=python"
        echo [WARN] Virtual environment not found. Using system python.
    ) else (
        color 0C
        echo [ERROR] Python is not installed or not found in PATH!
        echo Please install Python 3.10+ or create venv in backend\venv.
        pause
        exit /b 1
    )
)

:: Check if .env exists
if not exist ".env" (
    if exist ".env.example" (
        echo [INFO] .env not found. Creating from .env.example...
        copy ".env.example" ".env" >nul
        echo [OK] Created backend\.env with default configuration.
    )
)

:: Run database migrations
echo.
echo [1/2] Checking & Applying PostgreSQL Database Migrations...
"%PYTHON_EXE%" manage.py migrate
if %errorlevel% neq 0 (
    echo.
    echo [WARN] Migration had a warning or database connection issue.
    echo Ensure PostgreSQL service is running on port 5432 with database 'carelink_cb_db'.
)

:: Server Startup Information
echo.
echo ==============================================================================
echo  Server is starting! Access the services below:
echo.
echo  📊 Chat Management Dashboard : http://localhost:8000/
echo  🛡️ Django Admin Portal         : http://localhost:8000/admin/
echo     Username: admin  ^|  Password: admin
echo.
echo  🩺 AI Chat API Endpoint       : http://localhost:8000/api/ai-chat/
echo  📱 Mobile Emulator Base URL   : http://10.0.2.2:8000/
echo ==============================================================================
echo.
echo Press [Ctrl + C] or close this window to stop the server.
echo.

:: Start Django development server
"%PYTHON_EXE%" manage.py runserver 0.0.0.0:8000

if %errorlevel% neq 0 (
    echo.
    color 0C
    echo [ERROR] Server exited unexpectedly.
    pause
)
