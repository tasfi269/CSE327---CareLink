@echo off
title CareLink AI Health Assistant - Backend Server
color 0B

echo ==============================================================================
echo                 CareLink Digital Healthcare Platform
echo             Course: CSE327 - Software Engineering Project
echo               Feature 2.7: AI Health Assistant Chatbot
echo ==============================================================================
echo.

cd /d "%~dp0"
if not exist "manage.py" (
    if exist "%~dp0backend\manage.py" (
        cd /d "%~dp0backend"
    )
)

if not exist "venv\Scripts\python.exe" (
    echo [INFO] Virtual environment not found. Setting up new virtual environment...
    where python >nul 2>nul
    if %errorlevel% neq 0 (
        color 0C
        echo [ERROR] Python is not installed or not in PATH!
        echo Please install Python 3.10+ and re-run this script.
        pause
        exit /b 1
    )
    python -m venv venv
    echo [INFO] Installing dependencies from requirements.txt...
    venv\Scripts\python.exe -m pip install --upgrade pip
    venv\Scripts\python.exe -m pip install -r requirements.txt
    echo [OK] Virtual environment setup complete!
)

set "PYTHON_EXE=venv\Scripts\python.exe"

if not exist ".env" (
    if exist ".env.example" (
        echo [INFO] Creating .env from .env.example...
        copy ".env.example" ".env" >nul
        echo [OK] Created .env with default configuration.
    )
)

echo.
echo [1/2] Checking Database Migrations...
"%PYTHON_EXE%" manage.py migrate

if exist "init_admin.py" (
    "%PYTHON_EXE%" init_admin.py
)

echo.
echo ==============================================================================
echo  Server is starting! Access the services below:
echo.
echo  * Chat Management Dashboard : http://localhost:8000/
echo  * Django Admin Portal       : http://localhost:8000/admin/
echo    Username: admin  ^|  Password: admin
echo.
echo  * AI Chat API Endpoint     : http://localhost:8000/api/ai-chat/
echo  * Mobile Emulator Base URL : http://10.0.2.2:8000/
echo ==============================================================================
echo.
echo Press [Ctrl + C] or close this window to stop the server.
echo.

"%PYTHON_EXE%" manage.py runserver 0.0.0.0:8000

if %errorlevel% neq 0 (
    echo.
    color 0C
    echo [ERROR] Server exited unexpectedly.
    pause
)
