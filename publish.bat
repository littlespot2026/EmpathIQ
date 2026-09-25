@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo   EmpathIQ - Production Web Builder & Deployer
echo ========================================================

:: Determine GEMINI_API_KEY from argument %1 or system environment variable
set "API_KEY=%~1"
if "%API_KEY%"=="" (
    if defined GEMINI_API_KEY (
        set "API_KEY=%GEMINI_API_KEY%"
        echo [INFO] Detected GEMINI_API_KEY from environment variables.
    ) else (
        echo [INFO] No GEMINI_API_KEY passed. Building in smart simulation fallback mode.
        echo [INFO] Usage: publish.bat [YOUR_GEMINI_API_KEY]
    )
) else (
    echo [INFO] Using passed GEMINI_API_KEY parameter.
)

:: Build flutter web release
echo.
echo [1/3] Compiling Flutter Web release bundle...
if "%API_KEY%"=="" (
    call flutter build web --release
) else (
    call flutter build web --release --dart-define=GEMINI_API_KEY="%API_KEY%"
)

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Flutter build failed. Deployment aborted.
    exit /b %ERRORLEVEL%
)

:: Git commit and push
echo.
echo [2/3] Staging compiled web assets and configuration...
call git add build/web/ vercel.json .gitignore lib/

set "COMMIT_MSG=deploy: update web release bundle"
if not "%~2"=="" (
    set "COMMIT_MSG=%~2"
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
