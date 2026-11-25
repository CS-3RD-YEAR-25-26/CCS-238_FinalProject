# Runs every companion program and saves its output under .\outputs
# Usage (PowerShell, from the project folder):  .\run_all.ps1
# Needs: zig on PATH (winget install zig.zig); gforth on PATH, or gforth
# installed inside WSL (wsl sudo apt install gforth).

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$out = Join-Path $root 'outputs'
New-Item -ItemType Directory -Force $out | Out-Null

$programs = '01_recursion', '02_records', '03_compile_time_crc32', '04_rpn_errors'

Write-Host "zig $(zig version)"
foreach ($p in $programs) {
    Write-Host "--- zig/$p.zig"
    Push-Location (Join-Path $root 'zig')
    # stderr is kept separately: 02_records prints the allocator's leak report there
    zig run "$p.zig" 2> (Join-Path $out "zig_$p.stderr.txt") | Tee-Object (Join-Path $out "zig_$p.txt")
    Pop-Location
}

$native = Get-Command gforth -ErrorAction SilentlyContinue
foreach ($p in $programs) {
    Write-Host "--- forth/$p.fs"
    Push-Location (Join-Path $root 'forth')
    if ($native) {
        gforth "$p.fs" -e bye | Tee-Object (Join-Path $out "forth_$p.txt")
    } else {
        wsl gforth "$p.fs" -e bye | Tee-Object (Join-Path $out "forth_$p.txt")
    }
    Pop-Location
}
