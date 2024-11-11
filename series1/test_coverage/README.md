# Test Coverage Automation with JaCoCo

This repository contains two batch files that automate the process of running JUnit tests and generating test coverage reports using JaCoCo.

## Overview

The two batch files are:

1. **`run_commands.bat`**: Executes the tests and generates the coverage data (`jacoco.exec`).
2. **`generate_result.bat`**: Processes the coverage data and generates an HTML report.

## Usage

### 1. `run_commands.bat`

This batch file requires 3 variables as input:
1. **Path to the `bin` directory** of the project (e.g., `.\resources\smallsql0.21_src\bin`).
2. **Path to the JUnit JAR file** (e.g., `.\resources\smallsql0.21_src\lib\junit-3.8.1.jar`).
3. **Fully qualified name of the main test class** (e.g., `smallsql.junit.AllTests`).

The file sets the Java version to Java 5 and runs JaCoCo to execute the existing tests. The key commands in this batch file are:

```batch
set "JAVA_HOME=.\resources\jdk1.5.0_22"
set PATH=%JAVA_HOME%\bin;%PATH%
java -javaagent:.\resources\jacocoagent.jar=destfile=.\resources\jacoco.exec -cp "%var1%;%var2%" junit.textui.TestRunner %var3%