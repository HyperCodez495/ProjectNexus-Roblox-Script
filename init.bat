@echo off
echo ================================================
echo    Project Nexus - GitHub Upload Script
echo ================================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed!
    echo Please install Git from: https://git-scm.com/
    pause
    exit /b 1
)

REM Get GitHub username
set /p USERNAME="Enter your GitHub username: "
if "%USERNAME%"=="" (
    echo ERROR: Username cannot be empty!
    pause
    exit /b 1
)

echo.
echo Updating repository URLs...

REM Update main.lua
powershell -Command "(Get-Content main.lua) -replace 'YOUR_USERNAME/ProjectNexus', '%USERNAME%/ProjectNexus' | Set-Content main.lua"

REM Update loader.lua
powershell -Command "(Get-Content loader.lua) -replace 'YOUR_USERNAME/ProjectNexus', '%USERNAME%/ProjectNexus' | Set-Content loader.lua"

echo Done!
echo.
echo ================================================
echo    Git Repository Initialization
echo ================================================
echo.

REM Initialize git repository
git init
git add .
git commit -m "Initial commit - Project Nexus v1.0"
git branch -M main

echo.
echo ================================================
echo    Next Steps:
echo ================================================
echo.
echo 1. Create a new repository on GitHub named 'ProjectNexus'
echo 2. Run these commands:
echo.
echo    git remote add origin https://github.com/%USERNAME%/ProjectNexus.git
echo    git push -u origin main
echo.
echo 3. Your loadstring will be:
echo.
echo    loadstring(game:HttpGet("https://raw.githubusercontent.com/%USERNAME%/ProjectNexus/main/loader.lua"))()
echo.
echo ================================================

pause
