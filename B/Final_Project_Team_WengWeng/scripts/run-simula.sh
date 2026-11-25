#!/usr/bin/env bash

set -euo pipefail

ROOT="/workspace"
NAME="${1:-}"

# List available programs
if [[ -z "$NAME" || "$NAME" == "--list" ]]; then
    echo "===== AVAILABLE SIMULA PROGRAMS ====="

    find "$ROOT" -type f -name "*.sim" \
        -printf '%f\n' |
        sed 's/\.sim$//' |
        sort -u

    exit 0
fi

# Verify compiler and runtime files
if [[ "$NAME" == "--version" ]]; then
    command -v gnucim
    gcc --version
    ls -l /opt/simula-runtime
    exit 0
fi

# Locate the requested source file
mapfile -d '' SOURCES < <(
    find "$ROOT" -type f \
        -name "${NAME}.sim" -print0
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

# Create temporary Linux compilation directory
BUILD_DIR=$(mktemp -d)

trap 'rm -rf "$BUILD_DIR"' EXIT

# Copy source and runtime files
cp "$SOURCE" "$BUILD_DIR/program.sim"
cp /opt/simula-runtime/* "$BUILD_DIR/"

cd "$BUILD_DIR"

echo ""
echo "===== SIMULA 67 ====="
echo "Compiling $(basename "$SOURCE")..."

gnucim program.sim

# Verify that compilation produced an executable
if [[ ! -x "./program" ]]; then
    echo "Error: Executable was not generated."
    exit 1
fi

echo "Compilation successful!"
echo "Executing program..."
echo ""

./program
