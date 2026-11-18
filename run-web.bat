@echo off
title WasteFlow Web Dashboard Launcher
echo ========================================================
echo        Starting WasteFlow Web Dashboard
echo ========================================================
echo.

cd /d "%~dp0WasteFlow-Smart-Waste-Management-main\frontend"

echo Checking if frontend server is running...
powershell -Command "if (Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo Frontend server is already active at http://localhost:5173
) else (
    echo Starting frontend server on port 5173...
    start "WasteFlow Frontend Server" cmd /k "npm run dev"
    timeout /t 3 /nobreak >nul
)

echo Opening WasteFlow in default web browser...
start http://localhost:5173

echo.
echo ========================================================
echo You can also open the standalone HTML directly at:
echo %~dp0index.html
echo ========================================================
echo.
pause
