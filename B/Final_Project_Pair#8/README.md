# Smalltalk and Swift: A Comparative Programming-Language Project

**Course:** CCS 238 - Programming Languages  
**Authors:** Libuna & Ortillano (Pair 08)  
**Project directory:** `B/Final_Project_Pair#8/`

This project compares Smalltalk and Swift through a comparative term paper and three paired console applications: Campus Fare Pass, Study-Room Seat Counter, and Lost-and-Found Matcher. The six programs demonstrate polymorphism, encapsulation, collection processing, and interactive input handling.

Each program runs independently and accepts keyboard input. Add `--test` to run its built-in checks without interactive input. The applications use no third-party application libraries, GUI, or database.

## Contents

- [Repository structure](#repository-structure)
- [Companion program index](#companion-program-index)
- [Runtime requirements](#runtime-requirements)
- [Setup and verification](#setup-and-verification)
- [Run individual programs](#run-individual-programs)
- [Program behavior](#program-behavior)
- [Examples and expected output](#examples-and-expected-output)
- [Test results](#test-results)
- [Troubleshooting](#troubleshooting)
- [Working with the source files](#working-with-the-source-files)
- [Academic context and references](#academic-context-and-references)

## Repository structure

The tree below is relative to this project's root folder:

```text
Final_Project_Pair#8/
|-- README.md                                  # Project guide and execution commands
|-- Comparative_Term_Paper_Swift_vs_Smalltalk.pdf
`-- companion_programs/
    |-- smalltalk/                             # GNU Smalltalk implementations
    |   |-- campus_fare_pass.st
    |   |-- study_room_seat_counter.st
    |   `-- lost_and_found_matcher.st
    |-- swift/                                 # Swift implementations
    |   |-- campus_fare_pass.swift
    |   |-- study_room_seat_counter.swift
    |   `-- lost_and_found_matcher.swift
    |-- tools/
    |   |-- verify.py                          # Compile and verify all six programs
    |   |-- setup_smalltalk.py                 # Prepare a local Smalltalk runtime
    |   |-- smalltalk_runtime.json             # Pinned packages and SHA-256 hashes
    |   `-- gst-local.sh                       # Launch the extracted runtime
    `-- test_results/
        |-- campus_fare_pass.smalltalk.txt
        |-- campus_fare_pass.swift.txt
        |-- study_room_seat_counter.smalltalk.txt
        |-- study_room_seat_counter.swift.txt
        |-- lost_and_found_matcher.smalltalk.txt
        |-- lost_and_found_matcher.swift.txt
        `-- verification.json                 # Versions, cases, and recorded results
```

Setup creates `tmp/smalltalk-runtime/` under the project root. Verification creates `companion_programs/.build/` for compiled Swift executables. These generated directories are omitted from the source tree above.

## Companion program index

| Application | Main concepts | Smalltalk source | Swift source |
| --- | --- | --- | --- |
| Campus Fare Pass | Polymorphism and fare calculation | [campus_fare_pass.st](companion_programs/smalltalk/campus_fare_pass.st) | [campus_fare_pass.swift](companion_programs/swift/campus_fare_pass.swift) |
| Study-Room Seat Counter | Encapsulation and state validation | [study_room_seat_counter.st](companion_programs/smalltalk/study_room_seat_counter.st) | [study_room_seat_counter.swift](companion_programs/swift/study_room_seat_counter.swift) |
| Lost-and-Found Matcher | Collections, registration, and filtering | [lost_and_found_matcher.st](companion_programs/smalltalk/lost_and_found_matcher.st) | [lost_and_found_matcher.swift](companion_programs/swift/lost_and_found_matcher.swift) |

## Runtime requirements

The existing [verification record](companion_programs/test_results/verification.json) records the following language runtimes. These are tested versions, not claimed minimum versions.

| Component | Tested environment / requirement | Purpose |
| --- | --- | --- |
| Swift | Swift 6.4.2, Windows x86_64 | Compile and run the Swift programs |
| GNU Smalltalk | 3.2.5; Debian package 3.2.5-1.3+b2 amd64 in Ubuntu WSL | Run the Smalltalk scripts |
| Python | Previously documented setup: 3.14; helpers target Python 3.10+ | Run setup and verification tools |
| Windows terminal | PowerShell, with WSL distribution named `Ubuntu` for the local Smalltalk runtime | Run the commands below |

Python helpers use only the standard library; no pip packages are required. Swift compilation uses `-swift-version 6 -warnings-as-errors`.

GNU Smalltalk is a later dialect based on Smalltalk-80, using GNU bracket-style class declarations and `Eval` script syntax. These files are not Smalltalk-1972 source. Swift examples use the current protocol existential spelling `any`.

## Setup and verification

**All commands below start in `Final_Project_Pair#8/`, the folder containing this README.** If you opened the repository root instead, enter the project directory first:

```powershell
Set-Location '.\B\Final_Project_Pair#8'
```

### 1. Check Python and Swift

Make sure Python, Swift, and the Swift compiler are installed and available on `PATH`:

```powershell
python --version
swift --version
swiftc --version
```

### 2. Prepare GNU Smalltalk

If native `gst` is already installed, the verifier uses it. Otherwise, on Windows, confirm that WSL has a distribution named `Ubuntu`:

```powershell
wsl --list --verbose
```

With Ubuntu available, prepare the local runtime:

```powershell
python .\companion_programs\tools\setup_smalltalk.py
```

The setup helper downloads six pinned Debian packages, verifies their SHA-256 hashes against [smalltalk_runtime.json](companion_programs/tools/smalltalk_runtime.json), and extracts them into `tmp/smalltalk-runtime/`. It requires internet for initial downloads and `dpkg-deb` inside Ubuntu. It does not install global packages or modify WSL's package database.

Keep the generated runtime directory with the project, or rerun setup after copying the project. On Linux, setup requires Bash and `dpkg-deb` directly.

### 3. Build and test all programs

```powershell
python .\companion_programs\tools\verify.py
```

The verifier compiles all three Swift programs, runs all six built-in test suites, and compares scripted interactive sessions with expected output. It requires exact success markers and empty runtime diagnostics. It also checks that each program contains fewer than 50 physical lines, including comments, blanks, and tests. Any failure exits with a nonzero status.

A successful run ends with:

```text
PASS campus_fare_pass: both languages matched all expected sessions
PASS study_room_seat_counter: both languages matched all expected sessions
PASS lost_and_found_matcher: both languages matched all expected sessions
PASS all 6 programs; all interactive cases match the specification.
```

## Run individual programs

### Swift on Windows

After running the verifier, launch a compiled application:

```powershell
.\companion_programs\.build\campus_fare_pass.exe
.\companion_programs\.build\study_room_seat_counter.exe
.\companion_programs\.build\lost_and_found_matcher.exe
```

Run the commands separately to use each application. To compile just one application manually:

```powershell
New-Item -ItemType Directory -Force -Path '.\companion_programs\.build' | Out-Null
swiftc -swift-version 6 -warnings-as-errors '.\companion_programs\swift\campus_fare_pass.swift' -o '.\companion_programs\.build\campus_fare_pass.exe'
.\companion_programs\.build\campus_fare_pass.exe
```

Use compile-then-run on the documented Windows installation: direct `swift file.swift` execution previously encountered a toolchain JIT symbol-resolution error. On Linux/macOS, the verifier generates binaries without `.exe`; run, for example, `./companion_programs/.build/campus_fare_pass`.

### Smalltalk through Windows/WSL

With the local runtime prepared:

```powershell
wsl -d Ubuntu -- bash ./companion_programs/tools/gst-local.sh -f ./companion_programs/smalltalk/campus_fare_pass.st
wsl -d Ubuntu -- bash ./companion_programs/tools/gst-local.sh -f ./companion_programs/smalltalk/study_room_seat_counter.st
wsl -d Ubuntu -- bash ./companion_programs/tools/gst-local.sh -f ./companion_programs/smalltalk/lost_and_found_matcher.st
```

### Smalltalk with native GNU Smalltalk

```powershell
gst -f ./companion_programs/smalltalk/campus_fare_pass.st
gst -f ./companion_programs/smalltalk/study_room_seat_counter.st
gst -f ./companion_programs/smalltalk/lost_and_found_matcher.st
```

### Test one program

Append `--test` to the executable or Smalltalk command:

```powershell
.\companion_programs\.build\campus_fare_pass.exe --test
wsl -d Ubuntu -- bash ./companion_programs/tools/gst-local.sh -f ./companion_programs/smalltalk/campus_fare_pass.st --test
```

Both commands should print `campus_fare_pass tests passed`. Substitute another program name to run its checks. Run each source file in a separate process.

## Program behavior

### Campus Fare Pass

Enter a base fare in whole centavos: `2000` means PHP 20. The regular passenger pays 100%; the student pays 80%, rounded to the nearest centavo. Rates are fictional demonstration values.

Input must contain decimal digits only and fall between `0` and `9223372036854775807`. Invalid input displays an error and ends the session. The fare methods reject negative amounts with `nil`. Swift uses overflow-safe quotient/remainder arithmetic; Smalltalk supports arbitrary-size integers, while shared tests use signed 64-bit inputs.

### Study-Room Seat Counter

The interactive room has capacity 2 and starts empty.

| Choice | Action |
| --- | --- |
| `1` | Reserve one seat |
| `2` | Cancel one reservation |
| `3` | Show occupied and available seats |
| `4` | Exit |

Reserving a full room or cancelling an empty room fails without changing state. The model accepts zero capacity and rejects negative capacity. Swift restricts direct state mutation with a private setter; Smalltalk accesses instance variables through messages. Smalltalk's public initializer follows an initialization-only convention: valid explicit reinitialization resets the room, while invalid reinitialization is rejected before mutation.

### Lost-and-Found Matcher

The inventory starts with five sample records.

| Choice | Action |
| --- | --- |
| `1` | Register an item name, category, and location |
| `2` | Search by category and location |
| `3` | List the complete inventory |
| `4` | Exit |

Registration rejects blank or whitespace-only fields. Other nonblank categories and locations are allowed, and duplicate records are allowed. Search requires an exact, case-sensitive match on **both** category and location and preserves registration order. Whitespace is not silently trimmed.

Records exist only in memory. Exiting resets the inventory to its five samples on the next run. Both menu applications repeat until Exit or end-of-input; invalid choices leave state unchanged.

## Examples and expected output

The examples below agree with the saved test transcripts. Enter each input on its own line.

| Application | Input sequence | Expected result |
| --- | --- | --- |
| Fare Pass | `2000` | Regular: 2000 centavos; student: 1600 centavos |
| Fare Pass | `3` | Regular: 3 centavos; student: 2 centavos |
| Fare Pass | `-1` | Input validation error |
| Seat Counter | `1`, `1`, `1`, `4` | Two accepted reservations, then one rejected reservation |
| Matcher | `2`, `umbrella`, `library`, `4` | Blue umbrella, then Black umbrella |
| Matcher | `2`, `Umbrella`, `library`, `4` | `No matches.` because matching is case-sensitive |
| Matcher | `1`, `Green cap`, `clothing`, `lobby`, `2`, `clothing`, `lobby`, `4` | Registration succeeds; search returns Green cap |

For example, entering `2000` in either Fare Pass implementation produces:

```text
Base fare in centavos (2000 = PHP 20):
Regular fare: 2000 centavos
Student fare: 1600 centavos
```

## Test results

The [test_results directory](companion_programs/test_results/) contains saved interactive output for each language. The [verification.json](companion_programs/test_results/verification.json) report records runtime versions, built-in test markers, input/output cases, source line counts, and pass status.

The saved report records `PASS` for all six implementations. Rerun the verifier to check your own environment and regenerate the report and transcripts. GNU Smalltalk can return zero after a source error, so the verifier checks output and diagnostics in addition to exit codes.

## Troubleshooting

| Problem | What to check |
| --- | --- |
| `python`, `swift`, or `swiftc` is not recognized | Install the required tool and check its `PATH` entry. Reopen the terminal after changing environment settings. |
| WSL cannot find `Ubuntu` | Run `wsl --list --verbose`. The helpers expect a distribution named `Ubuntu`. |
| GNU Smalltalk cannot be found | Run the setup helper, or make native `gst` available on `PATH`. The verifier checks `tmp/smalltalk-runtime/` under this project and then in its parent directory. |
| Setup fails while downloading | Check internet access and retry. Package hashes must match the pinned manifest. |
| `dpkg-deb` is unavailable | Confirm it is available inside Ubuntu WSL, or directly on Linux when using Linux setup. |
| A source file or executable cannot be found | Start in the folder containing this README. Build Swift executables with the verifier before launching them. |
| Direct Swift execution produces a JIT error | Compile with `swiftc`, then run the generated executable using the commands above. |
| A matcher search returns no results | Check exact capitalization, whitespace, category, and location. Registrations disappear after exit. |
| Verification reports unexpected output | Read the reported program and case, then compare the source with the saved transcripts. A zero Smalltalk exit code alone does not prove success. |

## Working with the source files

Each file includes brief comments identifying language constructs and a built-in `--test` mode. Edit the corresponding Smalltalk and Swift files together when changing shared behavior, and rerun the verifier afterward. The under-50-line limit includes test code and comments.

The setup and verification helpers resolve paths relative to their own location. Commands in this README include `companion_programs/` because the README lives at the project root.

## Academic context and references

Read the [comparative term paper](Comparative_Term_Paper_Swift_vs_Smalltalk.pdf) for the accompanying analysis. The companion sources provide executable examples for comparing language behavior and design.

Primary technical references:

- [GNU Smalltalk invocation and syntax](https://www.gnu.org/software/smalltalk/manual/gst.html)
- [Swift protocols](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/)
- [Swift closures](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/closures/)
- [Debian GNU Smalltalk package](https://packages.debian.org/bullseye/gnu-smalltalk)
