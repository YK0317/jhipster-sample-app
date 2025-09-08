#!/bin/bash

# ===========================================
# GRADLE BUILD AUTOMATION SCRIPT
# Cross-platform build system for UECS2363 Assignment 2
# Supports: Linux, macOS, Unix systems
# ===========================================

PROJECT_NAME="JHipster Sample Application"
BUILD_SYSTEM="Gradle 8.4"

echo
echo "========================================"
echo "$PROJECT_NAME"
echo "$BUILD_SYSTEM Build Automation"
echo "$(date)"
echo "========================================"
echo

# Check if we're in the correct directory
if [ ! -f "build.gradle" ]; then
    echo "ERROR: build.gradle not found!"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Check Java
echo "Checking Java environment..."
if command -v java > /dev/null 2>&1; then
    echo "Java detected"
    java -version 2>&1 | head -1
else
    echo "ERROR: Java not found!"
    echo "Please install Java 21 JDK"
    exit 1
fi

# Check Gradle wrapper
echo "Checking Gradle wrapper..."
if [ -f "gradlew" ]; then
    echo "Gradle wrapper found"
    GRADLE_CMD="./gradlew"
    chmod +x ./gradlew
else
    echo "Using system Gradle"
    GRADLE_CMD="gradle"
fi

# Show help
if [ "$1" = "help" ]; then
    echo
    echo "Available Build Commands:"
    echo "  ./build-gradle.sh           - Full build"
    echo "  ./build-gradle.sh compile   - Compile sources only"
    echo "  ./build-gradle.sh jar       - Create JAR file"
    echo "  ./build-gradle.sh clean     - Clean build artifacts"
    echo "  ./build-gradle.sh test      - Run tests"
    echo "  ./build-gradle.sh help      - Show this help"
    echo
    exit 0
fi

echo
echo "Build Configuration:"
echo "  Mode: ${1:-default}"
echo "  Gradle: $GRADLE_CMD"
echo "  OS: $(uname -s)"
echo

# Execute based on argument
case "$1" in
    "clean")
        echo "Cleaning previous builds..."
        $GRADLE_CMD clean
        ;;
    "compile")
        echo "Compiling main sources..."
        $GRADLE_CMD compileJava
        ;;
    "jar")
        echo "Building JAR file..."
        $GRADLE_CMD compileJava jar
        ;;
    "test")
        echo "Running tests..."
        $GRADLE_CMD test
        ;;
    *)
        echo "Running build..."
        $GRADLE_CMD compileJava jar
        ;;
esac

# Check result
if [ $? -eq 0 ]; then
    echo
    echo "========================================"
    echo "BUILD SUCCESSFUL!"
    echo "========================================"
    echo
    
    if [ -d "build/libs" ]; then
        echo "Generated files:"
        for file in build/libs/*; do
            if [ -f "$file" ]; then
                echo "  - $(basename "$file")"
            fi
        done
        echo
    fi
    
    echo "Next steps:"
    echo "  - Run: java -jar build/libs/jhipster-sample-app-0.0.1-SNAPSHOT.jar"
    echo "  - Use: ./build-gradle.sh help for more options"
    echo
else
    echo
    echo "========================================"
    echo "BUILD FAILED!"
    echo "========================================"
    echo
    echo "Please check the error messages above."
    echo
    exit 1
fi
