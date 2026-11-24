#!/usr/bin/env bash

set -euo pipefail

ROOT="/workspace"
NAME="${1:-}"

# List programs when no argument is provided
if [[ -z "$NAME" || "$NAME" == "--list" ]]; then
    echo "===== AVAILABLE KOTLIN PROGRAMS ====="

    find "$ROOT" -type f -name "*.kt" \
        -printf '%f\n' |
        sed 's/\.kt$//' |
        sort -u

    exit 0
fi

# Verify compiler
if [[ "$NAME" == "--version" ]]; then
    java -version
    kotlinc -version
    exit 0
fi

# Locate the requested source file
mapfile -d '' SOURCES < <(
    find "$ROOT" -type f \
        -name "${NAME}.kt" -print0
)

if [[ ${#SOURCES[@]} -eq 0 ]]; then
    echo "Error: Program '$NAME' not found."
    exit 1
fi

if [[ ${#SOURCES[@]} -gt 1 ]]; then
    echo "Error: Duplicate source filenames."
    printf '%s\n' "${SOURCES[@]}"
    exit 1
fi

SOURCE="${SOURCES[0]}"

# Create temporary compilation directory
BUILD_DIR=$(mktemp -d)

trap 'rm -rf "$BUILD_DIR"' EXIT

JAR="$BUILD_DIR/program.jar"

cd "$(dirname "$SOURCE")"

echo ""
echo "===== KOTLIN ====="
echo "Compiling $(basename "$SOURCE")..."

kotlinc "$SOURCE" -include-runtime -d "$JAR"

echo "Compilation successful!"
echo "Executing program..."
echo ""

java -jar "$JAR"
