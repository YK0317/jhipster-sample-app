@echo off
setlocal EnableDelayedExpansion

REM Simple Gradle Build Automation Script
set "PROJECT_NAME=JHipster Sample Application"
set "BUILD_SYSTEM=Gradle 8.4"

echo.
echo ========================================
echo %PROJECT_NAME%
echo %BUILD_SYSTEM% Build Automation
echo %DATE% %TIME%
echo ========================================
echo.

REM Check if we're in the correct directory
if not exist "build.gradle" (
    echo ERROR: build.gradle not found!
    echo Please run this script from the project root directory
    pause
    exit /b 1
)

REM Check Java
echo Checking Java environment...
java -version >nul 2>&1
if !errorlevel! equ 0 (
    echo Java detected
) else (
    echo ERROR: Java not found!
    pause
    exit /b 1
)

REM Check Gradle wrapper
echo Checking Gradle wrapper...
if exist "gradlew.bat" (
    echo Gradle wrapper found
    set "GRADLE_CMD=gradlew.bat"
) else (
    echo Using system Gradle
    set "GRADLE_CMD=gradle"
)

REM Show help
if "%1"=="help" (
    echo.
    echo Available Build Commands:
    echo   build-gradle-simple.bat         - Full build
    echo   build-gradle-simple.bat compile - Compile sources only
    echo   build-gradle-simple.bat jar     - Create JAR file
    echo   build-gradle-simple.bat clean   - Clean build artifacts
    echo   build-gradle-simple.bat help    - Show this help
    echo.
    goto :EOF
)

echo.
echo Build Configuration:
echo   Mode: %1
echo   Gradle: !GRADLE_CMD!
echo.

REM Execute based on argument
if "%1"=="clean" (
    echo Cleaning previous builds...
    call !GRADLE_CMD! clean
    goto :success
)

if "%1"=="compile" (
    echo Compiling main sources...
    call !GRADLE_CMD! compileJava
    goto :success
)

if "%1"=="jar" (
    echo Building JAR file...
    call !GRADLE_CMD! compileJava jar
    goto :success
)

REM Default build
echo Running build...
call !GRADLE_CMD! compileJava jar

:success
if !errorlevel! equ 0 (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo.
    
    if exist "build\libs" (
        echo Generated files:
        for %%f in (build\libs\*) do (
            echo   - %%~nxf
        )
        echo.
    )
    
    echo Next steps:
    echo   - Run 'java -jar build\libs\jhipster-sample-app-0.0.1-SNAPSHOT.jar'
    echo   - Use 'build-gradle-simple.bat help' for more options
    echo.
) else (
    echo.
    echo ========================================
    echo BUILD FAILED!
    echo ========================================
    echo.
    echo Please check the error messages above.
    echo.
)

goto :EOF
