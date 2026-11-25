#!/bin/sh
# Runs every companion program and saves its output under ./outputs
# Usage (Linux, macOS or WSL, from the project folder):  sh run_all.sh
# Needs: zig and gforth on PATH (e.g. sudo apt install gforth).
set -e
cd "$(dirname "$0")"
mkdir -p outputs

echo "zig $(zig version)"
for p in 01_recursion 02_records 03_compile_time_crc32 04_rpn_errors; do
    echo "--- zig/$p.zig"
    (cd zig && zig run "$p.zig" 2>"../outputs/zig_$p.stderr.txt" | tee "../outputs/zig_$p.txt")
done

gforth -e 'version-string type cr bye'
for p in 01_recursion 02_records 03_compile_time_crc32 04_rpn_errors; do
    echo "--- forth/$p.fs"
    (cd forth && gforth "$p.fs" -e bye | tee "../outputs/forth_$p.txt")
done
