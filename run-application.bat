@echo off
title WasteFlow Full-Stack Launcher
echo =======================================================================
echo          Starting WasteFlow Smart Waste Management System
echo =======================================================================
echo.

cd /d "%~dp0WasteFlow-Smart-Waste-Management-main"

echo [1/3] Checking Spring Boot Backend (Port 8080)...
powershell -Command "if (Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [OK] Backend service is active on http://localhost:8080
) else (
    echo [STARTING] Launching Spring Boot Backend with embedded database...
    start "WasteFlow Backend (Port 8080)" cmd /k "cd backend && .\mvnw.cmd spring-boot:run \"-Dspring-boot.run.arguments=--spring.datasource.url=jdbc:h2:file:./wasteflow-dev;MODE=MySQL;DB_CLOSE_DELAY=-1 --spring.datasource.driver-class-name=org.h2.Driver --spring.datasource.username=sa --spring.datasource.password= --spring.jpa.hibernate.ddl-auto=create --spring.flyway.enabled=false --spring.data.mongodb.uri=mongodb://localhost:27017/wasteflow\""
    echo Waiting for backend to initialize on port 8080...
    timeout /t 10 /nobreak >nul
)

echo.
echo [2/3] Checking React Frontend Dev Server (Port 5173)...
powershell -Command "if (Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %ERRORLEVEL% EQU 0 (
    echo [OK] Frontend dev server is active on http://localhost:5173
) else (
    echo [STARTING] Launching Frontend Development Server...
    start "WasteFlow Frontend (Port 5173)" cmd /k "cd frontend && npm run dev"
    timeout /t 4 /nobreak >nul
)

echo.
echo [3/3] Opening WasteFlow Application in Web Browser...
start http://localhost:5173

echo.
echo =======================================================================
echo Application is now live:
echo  - Live Interactive UI:   http://localhost:5173
echo  - Standalone Single HTML: %~dp0index.html
echo  - REST API & Actuator:   http://localhost:8080/actuator/health
echo =======================================================================
echo.
pause
