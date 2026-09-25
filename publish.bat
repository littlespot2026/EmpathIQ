@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo   EmpathIQ - Production Web Builder & Deployer
echo   Security: Serverless Backend Proxy Architecture
echo ========================================================

:: Build clean flutter web release without exposing any credentials in frontend JS
echo.
echo [1/3] Compiling Flutter Web release bundle (key-free client)...
call flutter build web --release

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Flutter build failed. Deployment aborted.
    exit /b %ERRORLEVEL%
)

:: Git commit and push
echo.
echo [2/3] Staging compiled web assets and configuration...
call git add build/web/ api/ vercel.json .gitignore lib/ publish.bat publish.sh

set "COMMIT_MSG=deploy: update web release bundle with secure serverless proxy"
if not "%~1"=="" (
    set "COMMIT_MSG=%~1"
)

echo [3/3] Committing and pushing to origin main...
call git commit -m "%COMMIT_MSG%"
call git push origin main

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Git push failed. Please check git credentials.
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================================
echo   SUCCESS! Deployment submitted to Vercel production:
echo   https://empath-iq-theta.vercel.app/
echo ========================================================
