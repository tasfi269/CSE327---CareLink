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

if exist "venv\Scripts\python.exe" (
    set "PYTHON_EXE=venv\Scripts\python.exe"
    echo [OK] Using virtual environment at: venv
) else (
    set "PYTHON_EXE=python"
    echo [INFO] Using system python command.
)

if not exist ".env" (
    if exist ".env.example" (
        echo [INFO] Creating .env from .env.example...
        copy ".env.example" ".env" >nul
    )
)

echo.
echo [1/2] Checking Database Migrations...
"%PYTHON_EXE%" manage.py migrate

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
