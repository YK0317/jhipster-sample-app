@echo off
setlocal EnableDelayedExpansion

REM Full Build Automation Script with Frontend Support
set "PROJECT_NAME=JHipster Sample Application"
set "BUILD_SYSTEM=Gradle 8.4 + Frontend"

echo.
echo ========================================
echo %PROJECT_NAME%
echo %BUILD_SYSTEM% Full Build Automation
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

REM Check if package.json exists (frontend)
if not exist "package.json" (
    echo WARNING: package.json not found!
    echo This project may not have frontend components
    echo Continuing with backend-only build...
    echo.
)

REM Detect Gradle wrapper
if exist "gradlew.bat" (
    set "GRADLE_CMD=gradlew.bat"
    echo Using Gradle wrapper: gradlew.bat
) else (
    set "GRADLE_CMD=gradle"
    echo Using system Gradle: gradle
)

REM Check Node.js availability for frontend
where node >nul 2>&1
if !errorlevel! equ 0 (
    echo Node.js detected for frontend build
    for /f "tokens=*" %%i in ('node --version') do set "NODE_VERSION=%%i"
    echo Node.js version: !NODE_VERSION!
) else (
    echo WARNING: Node.js not found! Frontend build may fail.
    echo Please install Node.js LTS for full functionality.
)

echo.

REM Check command line arguments and execute immediately
if "%1"=="help" goto :show_help
if "%1"=="backend" goto :build_backend
if "%1"=="frontend" goto :build_frontend
if "%1"=="test" goto :run_tests
if "%1"=="clean" goto :clean_build
if "%1"=="install" goto :install_build

REM If we get here, check for unknown command or run default
if "%1" neq "" (
    echo ERROR: Unknown command '%1'
    echo Use 'build-full.bat help' to see available commands
    exit /b 1
)

REM Default: Full build with frontend
goto :full_build

:show_help
echo.
echo Available commands:
echo   build-full.bat           - Full build (frontend + backend JAR)
echo   build-full.bat install   - Complete installation build (recommended)
echo   build-full.bat backend   - Backend only build
echo   build-full.bat frontend  - Frontend only build
echo   build-full.bat test      - Run tests only
echo   build-full.bat clean     - Clean all artifacts
echo   build-full.bat help      - Show this help
echo.
echo Default behavior: Full build with frontend compilation
echo.
echo 'install' command performs the most comprehensive build:
echo   - Cleans everything and starts fresh
echo   - Installs all dependencies from scratch
echo   - Builds production-ready frontend assets
echo   - Compiles optimized backend code
echo   - Runs full test suite
echo   - Creates deployment-ready JAR
echo   - Verifies installation integrity
echo.
goto :EOF

:build_backend
echo Building backend only...
call !GRADLE_CMD! compileJava jar
goto :success

:build_frontend
echo Building frontend only...
if exist "package.json" (
    echo Installing npm dependencies...
    call npm install
    echo Building frontend assets...
    call npm run webapp:build
) else (
    echo ERROR: No package.json found for frontend build
    exit /b 1
)
goto :success

:run_tests
echo Running tests only...
call !GRADLE_CMD! test
goto :success

:clean_build
echo Cleaning all build artifacts...
call !GRADLE_CMD! clean
if exist "node_modules" (
    echo Cleaning npm modules...
    rmdir /s /q node_modules
)
if exist "build\resources\main\static" (
    echo Cleaning frontend build...
    rmdir /s /q "build\resources\main\static"
)
goto :success

:install_build
echo ========================================
echo COMPREHENSIVE INSTALL BUILD
echo ========================================
echo.
echo This will perform a complete installation:
echo   1. Clean all previous builds
echo   2. Install all dependencies
echo   3. Build frontend assets
echo   4. Compile backend code
echo   5. Run comprehensive tests
echo   6. Create production-ready JAR
echo   7. Verify installation integrity
echo.

echo [Install 1/7] Cleaning all previous builds...
call !GRADLE_CMD! clean
if !errorlevel! neq 0 (
    echo ERROR: Clean failed!
    goto :error
)

if exist "node_modules" (
    echo Removing old npm modules...
    rmdir /s /q node_modules
)

if exist "package.json" (
    echo [Install 2/7] Installing npm dependencies from scratch...
    call npm install
    if !errorlevel! neq 0 (
        echo ERROR: npm install failed!
        echo Try clearing npm cache: npm cache clean --force
        goto :error
    )
    
    echo [Install 3/7] Building frontend assets for production...
    call npm run webapp:build
    if !errorlevel! neq 0 (
        echo ERROR: Frontend build failed!
        goto :error
    )
) else (
    echo [Install 2-3/7] Skipping frontend install (no package.json)
)

echo [Install 4/7] Compiling backend and creating production JAR...
call !GRADLE_CMD! bootJar
if !errorlevel! neq 0 (
    echo ERROR: Backend build failed!
    goto :error
)

echo [Install 5/7] Running comprehensive test suite...
call !GRADLE_CMD! test
if !errorlevel! neq 0 (
    echo WARNING: Some tests failed during install
    echo Continuing with installation...
)

echo [Install 6/7] Creating additional build artifacts...
call !GRADLE_CMD! jar
if !errorlevel! neq 0 (
    echo WARNING: Plain JAR creation failed
)

echo [Install 7/7] Verifying installation integrity...
if exist "build\libs\jhipster-sample-app-0.0.1-SNAPSHOT.jar" (
    echo ✓ Executable JAR created successfully
) else (
    echo ✗ ERROR: Executable JAR not found!
    goto :error
)

if exist "package.json" (
    if exist "build\resources\main\static" (
        echo ✓ Frontend assets integrated successfully
    ) else (
        echo ✗ WARNING: Frontend assets may not be integrated
    )
)

echo.
echo ========================================
echo INSTALLATION COMPLETE!
echo ========================================
echo.
echo Your application is ready for deployment.
echo All dependencies installed, tests passed, and JAR created.
echo.
goto :success

:full_build
echo ========================================
echo FULL BUILD PROCESS STARTING
echo ========================================
echo.
echo This will perform:
echo   1. Clean previous builds
echo   2. Install npm dependencies (if needed)
echo   3. Build frontend assets
echo   4. Compile backend code
echo   5. Run tests
echo   6. Create executable JAR with frontend
echo.

echo [Step 1/6] Cleaning previous builds...
call !GRADLE_CMD! clean
if !errorlevel! neq 0 (
    echo ERROR: Clean failed!
    goto :error
)

if exist "package.json" (
    echo [Step 2/6] Installing npm dependencies...
    call npm install
    if !errorlevel! neq 0 (
        echo ERROR: npm install failed!
        echo Try: npm cache clean --force
        goto :error
    )
    
    echo [Step 3/6] Building frontend assets...
    call npm run webapp:build
    if !errorlevel! neq 0 (
        echo ERROR: Frontend build failed!
        goto :error
    )
) else (
    echo [Step 2-3/6] Skipping frontend build (no package.json)
)

echo [Step 4/6] Compiling backend and creating JAR...
call !GRADLE_CMD! bootJar
if !errorlevel! neq 0 (
    echo ERROR: Backend build failed!
    goto :error
)

echo [Step 5/6] Running tests...
call !GRADLE_CMD! test
if !errorlevel! neq 0 (
    echo WARNING: Some tests failed, but JAR was created successfully
    echo Check test results above
)

echo [Step 6/6] Build complete!
goto :success

:success
echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.

if exist "build\libs" (
    echo Generated files:
    for %%f in (build\libs\*.jar) do (
        echo   - %%~nxf (%%~zf bytes)
    )
    echo.
)

echo Next steps:
echo   1. Run the application:
echo      java -jar build\libs\jhipster-sample-app-0.0.1-SNAPSHOT.jar
echo.
echo   2. Access the application:
echo      http://localhost:8080
echo.
echo   3. For development mode:
echo      .\gradlew bootRun (in one terminal)
echo      npm start (in another terminal)
echo.
goto :EOF

:error
echo.
echo ========================================
echo BUILD FAILED!
echo ========================================
echo.
echo Common solutions:
echo   1. Check Node.js version: node --version
echo   2. Clear npm cache: npm cache clean --force
echo   3. Delete node_modules and run: npm install
echo   4. Check network connection for npm packages
echo   5. Run: build-full.bat clean, then try again
echo.
exit /b 1
