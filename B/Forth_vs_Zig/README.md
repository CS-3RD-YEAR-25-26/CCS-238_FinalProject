# Forth (1970) vs. Zig (2016): CCS 238 Final Project

**Line of inquiry:** low-level control, stack vs. explicit memory, compile-time execution.

Four small problems, each solved in both languages (8 programs in total). Every
program compiles and runs; captured output is in [`outputs/`](outputs/).

| # | Problem | Forth | Zig | Paper topic |
|---|---------|-------|-----|-------------|
| 1 | Recursive factorial (overflow behavior) and Towers of Hanoi | [`forth/01_recursion.fs`](forth/01_recursion.fs) | [`zig/01_recursion.zig`](zig/01_recursion.zig) | Subprograms and parameter passing |
| 2 | Student records: static vs. heap memory, leak detection | [`forth/02_records.fs`](forth/02_records.fs) | [`zig/02_records.zig`](zig/02_records.zig) | Names, bindings, scope, lifetime |
| 3 | CRC-32 with lookup tables built at compile time | [`forth/03_compile_time_crc32.fs`](forth/03_compile_time_crc32.fs) | [`zig/03_compile_time_crc32.zig`](zig/03_compile_time_crc32.zig) | Language implementation (compile-time execution) |
| 4 | Reverse-Polish calculator with error handling | [`forth/04_rpn_errors.fs`](forth/04_rpn_errors.fs) | [`zig/04_rpn_errors.zig`](zig/04_rpn_errors.zig) | Exception handling; syntax and semantics |

## Toolchains used

| Language | Implementation | Version tested | Platform |
|----------|---------------|----------------|----------|
| Forth | Gforth (GNU Forth) | 0.7.3 (Ubuntu package `0.7.3+dfsg`) | Ubuntu on WSL 2 |
| Zig | Zig compiler | 0.17.0 | Windows 11 x86_64 |

Zig is pre-1.0 and its standard library changes between releases. These
programs use the 0.17.0 I/O interface (`std.process.Init`, `std.Io.File.Writer`)
and will not compile unchanged on much older Zig versions.

## Installing

**Zig** (Windows):

```bash
winget install zig.zig
```

On Linux or macOS, download 0.17.0 from <https://ziglang.org/download/>.

**Gforth** (Linux, or WSL on Windows):

```bash
sudo apt install gforth
```

## Running one program

Run the Forth programs from inside `forth/` and the Zig programs from inside `zig/`.

```bash
gforth 01_recursion.fs -e bye
```

```bash
zig run 01_recursion.zig
```

`-e bye` tells Gforth to exit after loading the file; without it Gforth stays
in its interactive interpreter, where you can call any word, for example
`5 factorial .` or `s" hello" crc32 .hex32`.

On Windows with Gforth installed only in WSL, prefix the Forth command with `wsl`:

```bash
wsl gforth 01_recursion.fs -e bye
```

## Running everything

Both scripts run all eight programs and write their output to `outputs/`.

Windows PowerShell (uses native `gforth` if present, otherwise `wsl gforth`):

```bash
.\run_all.ps1
```

Linux, macOS, or WSL:

```bash
sh run_all.sh
```

## What to look for in the output

- **01_recursion:** Forth prints a negative number for 21! (silent 64-bit
  wraparound); Zig prints `error.Overflow`. Both print the same seven Hanoi moves.
- **02_records:** Forth tracks leaks with a hand-written counter; Zig's
  `DebugAllocator` reports a deliberate leak by itself (on stderr). The same Zig
  code also runs on a 512-byte buffer on the stack.
- **03_compile_time_crc32:** both print CRC-32 `CBF43926` for `"123456789"`;
  Forth's `see crc-entry` shows the loop unrolled by an `IMMEDIATE` word. To see
  Zig reject an invalid polynomial at compile time, uncomment the `Broken` line.
- **04_rpn_errors:** `0 7 - 2 /` gives -4 in Forth (floored division) and -3 in
  Zig (truncating); `9223372036854775807 1 +` wraps in Forth and is an
  overflow error in Zig.

## Repository layout

```
forth/          Forth sources (.fs)
zig/            Zig sources (.zig)
outputs/        captured program output (.txt) and console screenshots (screenshots/)
run_all.ps1     run everything (Windows)
run_all.sh      run everything (Linux / macOS / WSL)
```
