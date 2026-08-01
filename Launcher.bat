@echo off
:: ═══════════════════════════════════════════════════════════════
:: YTDL Toolkit — Launcher
:: Double-click this file to start the toolkit.
:: ═══════════════════════════════════════════════════════════════

:: Set UTF-8 code page for proper character display
chcp 65001 >nul 2>&1

:: Set console title
title YTDL Toolkit

:: Set working directory to the script's folder
cd /d "%~dp0"

:: Check if PowerShell is available
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ERROR: PowerShell is not available on this system.
    echo  YTDL Toolkit requires Windows PowerShell 5.1 or later.
    echo.
    echo  Press any key to exit...
    pause >nul
    exit /b 1
)

:: Launch the toolkit with execution policy bypass
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Toolkit.ps1" %*

:: Capture exit code
set exitcode=%errorlevel%

:: If the toolkit exited with an error, pause so the user can see
if %exitcode% neq 0 (
    echo.
    echo  The toolkit exited with code %exitcode%.
    echo  Press any key to close...
    pause >nul
)

exit /b %exitcode%
