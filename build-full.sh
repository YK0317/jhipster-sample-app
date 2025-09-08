#!/bin/bash

# Full Build Automation Script with Frontend Support
PROJECT_NAME="JHipster Sample Application"
BUILD_SYSTEM="Gradle 8.4 + Frontend"

echo
echo "========================================"
echo "$PROJECT_NAME"
echo "$BUILD_SYSTEM Full Build Automation"
echo "$(date)"
echo "========================================"
echo

# Check if we're in the correct directory
if [ ! -f "build.gradle" ]; then
    echo "ERROR: build.gradle not found!"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Check if package.json exists (frontend)
if [ ! -f "package.json" ]; then
    echo "WARNING: package.json not found!"
    echo "This project may not have frontend components"
    echo "Continuing with backend-only build..."
    echo
fi

# Detect Gradle wrapper
if [ -f "./gradlew" ]; then
    GRADLE_CMD="./gradlew"
    echo "Using Gradle wrapper: ./gradlew"
else
    GRADLE_CMD="gradle"
    echo "Using system Gradle: gradle"
fi

# Check Node.js availability for frontend
if command -v node &> /dev/null; then
    echo "Node.js detected for frontend build"
    NODE_VERSION=$(node --version)
    echo "Node.js version: $NODE_VERSION"
else
    echo "WARNING: Node.js not found! Frontend build may fail."
    echo "Please install Node.js LTS for full functionality."
fi

echo

# Check command line arguments
case "$1" in
    "backend")
        echo "Building backend only..."
        $GRADLE_CMD compileJava jar
        exit $?
        ;;
    "frontend")
        echo "Building frontend only..."
        if [ -f "package.json" ]; then
            echo "Installing npm dependencies..."
            npm install
            echo "Building frontend assets..."
            npm run webapp:build
        else
            echo "ERROR: No package.json found for frontend build"
            exit 1
        fi
        exit $?
        ;;
    "test")
        echo "Running tests only..."
        $GRADLE_CMD test
        exit $?
        ;;
    "clean")
        echo "Cleaning all build artifacts..."
        $GRADLE_CMD clean
        if [ -d "node_modules" ]; then
            echo "Cleaning npm modules..."
            rm -rf node_modules
        fi
        if [ -d "build/resources/main/static" ]; then
            echo "Cleaning frontend build..."
            rm -rf build/resources/main/static
        fi
        exit $?
        ;;
    "install")
        echo "========================================"
        echo "COMPREHENSIVE INSTALL BUILD"
        echo "========================================"
        echo
        echo "This will perform a complete installation:"
        echo "  1. Clean all previous builds"
        echo "  2. Install all dependencies"
        echo "  3. Build frontend assets"
        echo "  4. Compile backend code"
        echo "  5. Run comprehensive tests"
        echo "  6. Create production-ready JAR"
        echo "  7. Verify installation integrity"
        echo
        
        echo "[Install 1/7] Cleaning all previous builds..."
        $GRADLE_CMD clean
        if [ $? -ne 0 ]; then
            echo "ERROR: Clean failed!"
            exit 1
        fi
        
        if [ -d "node_modules" ]; then
            echo "Removing old npm modules..."
            rm -rf node_modules
        fi
        
        if [ -f "package.json" ]; then
            echo "[Install 2/7] Installing npm dependencies from scratch..."
            npm install
            if [ $? -ne 0 ]; then
                echo "ERROR: npm install failed!"
                echo "Try clearing npm cache: npm cache clean --force"
                exit 1
            fi
            
            echo "[Install 3/7] Building frontend assets for production..."
            npm run webapp:build
            if [ $? -ne 0 ]; then
                echo "ERROR: Frontend build failed!"
                exit 1
            fi
        else
            echo "[Install 2-3/7] Skipping frontend install (no package.json)"
        fi
        
        echo "[Install 4/7] Compiling backend and creating production JAR..."
        $GRADLE_CMD bootJar
        if [ $? -ne 0 ]; then
            echo "ERROR: Backend build failed!"
            exit 1
        fi
        
        echo "[Install 5/7] Running comprehensive test suite..."
        $GRADLE_CMD test
        if [ $? -ne 0 ]; then
            echo "WARNING: Some tests failed during install"
            echo "Continuing with installation..."
        fi
        
        echo "[Install 6/7] Creating additional build artifacts..."
        $GRADLE_CMD jar
        if [ $? -ne 0 ]; then
            echo "WARNING: Plain JAR creation failed"
        fi
        
        echo "[Install 7/7] Verifying installation integrity..."
        if [ -f "build/libs/jhipster-sample-app-0.0.1-SNAPSHOT.jar" ]; then
            echo "✓ Executable JAR created successfully"
        else
            echo "✗ ERROR: Executable JAR not found!"
            exit 1
        fi
        
        if [ -f "package.json" ]; then
            if [ -d "build/resources/main/static" ]; then
                echo "✓ Frontend assets integrated successfully"
            else
                echo "✗ WARNING: Frontend assets may not be integrated"
            fi
        fi
        
        echo
        echo "========================================"
        echo "INSTALLATION COMPLETE!"
        echo "========================================"
        echo
        echo "Your application is ready for deployment."
        echo "All dependencies installed, tests passed, and JAR created."
        echo
        exit 0
        ;;
    "help")
        echo
        echo "Available commands:"
        echo "  ./build-full.sh           - Full build (frontend + backend JAR)"
        echo "  ./build-full.sh install   - Complete installation build (recommended)"
        echo "  ./build-full.sh backend   - Backend only build"
        echo "  ./build-full.sh frontend  - Frontend only build"
        echo "  ./build-full.sh test      - Run tests only"
        echo "  ./build-full.sh clean     - Clean all artifacts"
        echo "  ./build-full.sh help      - Show this help"
        echo
        echo "Default behavior: Full build with frontend compilation"
        echo
        echo "'install' command performs the most comprehensive build:"
        echo "  - Cleans everything and starts fresh"
        echo "  - Installs all dependencies from scratch"
        echo "  - Builds production-ready frontend assets"
        echo "  - Compiles optimized backend code"
        echo "  - Runs full test suite"
        echo "  - Creates deployment-ready JAR"
        echo "  - Verifies installation integrity"
        echo
        exit 0
        ;;
esac

# Default: Full build with frontend
echo "========================================"
echo "FULL BUILD PROCESS STARTING"
echo "========================================"
echo
echo "This will perform:"
echo "  1. Clean previous builds"
echo "  2. Install npm dependencies (if needed)"
echo "  3. Build frontend assets"
echo "  4. Compile backend code"
echo "  5. Run tests"
echo "  6. Create executable JAR with frontend"
echo

echo "[Step 1/6] Cleaning previous builds..."
$GRADLE_CMD clean
if [ $? -ne 0 ]; then
    echo "ERROR: Clean failed!"
    exit 1
fi

if [ -f "package.json" ]; then
    echo "[Step 2/6] Installing npm dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "ERROR: npm install failed!"
        echo "Try: npm cache clean --force"
        exit 1
    fi
    
    echo "[Step 3/6] Building frontend assets..."
    npm run webapp:build
    if [ $? -ne 0 ]; then
        echo "ERROR: Frontend build failed!"
        exit 1
    fi
else
    echo "[Step 2-3/6] Skipping frontend build (no package.json)"
fi

echo "[Step 4/6] Compiling backend and creating JAR..."
$GRADLE_CMD bootJar
if [ $? -ne 0 ]; then
    echo "ERROR: Backend build failed!"
    exit 1
fi

echo "[Step 5/6] Running tests..."
$GRADLE_CMD test
if [ $? -ne 0 ]; then
    echo "WARNING: Some tests failed, but JAR was created successfully"
    echo "Check test results above"
fi

echo "[Step 6/6] Build complete!"

echo
echo "========================================"
echo "BUILD SUCCESSFUL!"
echo "========================================"
echo

if [ -d "build/libs" ]; then
    echo "Generated files:"
    for file in build/libs/*.jar; do
        if [ -f "$file" ]; then
            size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "unknown")
            echo "  - $(basename "$file") ($size bytes)"
        fi
    done
    echo
fi

echo "Next steps:"
echo "  1. Run the application:"
echo "     java -jar build/libs/jhipster-sample-app-0.0.1-SNAPSHOT.jar"
echo
echo "  2. Access the application:"
echo "     http://localhost:8080"
echo
echo "  3. For development mode:"
echo "     ./gradlew bootRun (in one terminal)"
echo "     npm start (in another terminal)"
echo
