@echo off
if "%~1"=="" (
    echo Usage: run_commands.bat var1 var2
    exit /b 1
)

set var1=%~1
set var2=%~2

java -jar .\resources\jacococli.jar report .\resources\jacoco.exec --classfiles "%var1%" --sourcefiles "%var2%" --html ".\resources\results"
if errorlevel 1 (
    echo Coverage report generation failed.
    exit /b 1
)

start "" ".\resources\results\index.html"