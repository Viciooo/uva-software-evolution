@echo off
if "%~1"=="" (
    echo Usage: run_commands.bat var1 var2 var3
    exit /b 1
)

set "JAVA_HOME=.\resources\jdk1.5.0_22"
set PATH=%JAVA_HOME%\bin;%PATH%

set var1=%~1
set var2=%~2
set var3=%~3

java -javaagent:.\resources\jacocoagent.jar=destfile=.\resources\jacoco.exec -cp "%var1%;%var2%" junit.textui.TestRunner %var3%
if errorlevel 1 (
    echo Test execution failed.
    exit /b 1
)
