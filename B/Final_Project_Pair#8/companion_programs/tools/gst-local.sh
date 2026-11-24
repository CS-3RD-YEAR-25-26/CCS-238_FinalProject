#!/usr/bin/env bash
set -eu
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$PROJECT_DIR/../tmp/smalltalk-runtime/root"
if [[ ! -f "$RUNTIME_DIR/usr/lib/gnu-smalltalk/gst.im" ]]; then
    RUNTIME_DIR="$PROJECT_DIR/../../tmp/smalltalk-runtime/root"
fi
export LD_LIBRARY_PATH="$RUNTIME_DIR/usr/lib:$RUNTIME_DIR/usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$RUNTIME_DIR/usr/bin/gst" -I "$RUNTIME_DIR/usr/lib/gnu-smalltalk/gst.im" "$@"
