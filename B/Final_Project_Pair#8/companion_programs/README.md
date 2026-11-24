# Pair 08 companion programs

Libuna & Ortillano | CCS 238 | Smalltalk and Swift

Three independent console programs, each implemented in both languages. Normal runs accept keyboard input; add `--test` for separate boundary and rejection checks. No external application libraries, GUI or database.

| Problem | Smalltalk | Swift |
| --- | --- | --- |
| Campus Fare Pass | `smalltalk/campus_fare_pass.st` | `swift/campus_fare_pass.swift` |
| Study-Room Seat Counter | `smalltalk/study_room_seat_counter.st` | `swift/study_room_seat_counter.swift` |
| Lost-and-Found Matcher | `smalltalk/lost_and_found_matcher.st` | `swift/lost_and_found_matcher.swift` |

`tools/verify.py` builds and tests everything. `test_results/` contains actual output and a machine-readable verification record.

## Tested environment

- Swift 6.4.2, Windows x86_64, compiled with `-swift-version 6 -warnings-as-errors`.
- GNU Smalltalk 3.2.5, Debian 3.2.5-1.3+b2 amd64 runtime, inside the existing Ubuntu WSL distribution.
- Python 3.14 used for setup and verification; helpers target Python 3.10+ and use only its standard library.

GNU Smalltalk is a later dialect based on Smalltalk-80, with GNU bracket-style class declarations and `Eval` script syntax. These files are not Smalltalk-1972 source. Swift uses the current protocol existential spelling `any`. Preserve these distinctions when studying historical design.

## Run and test everything

From this folder in PowerShell:

```powershell
python companion_programs/tools/verify.py 
```

The verifier recompiles all three Swift files, runs all six test suites, requires exact success markers and empty runtime diagnostics, then checks scripted interactive sessions against independent expected fixtures. It also enforces fewer than 50 physical lines per program, including blanks, comments and tests. Any failure exits nonzero. GNU Smalltalk can return zero after a source error, so exit codes alone are insufficient.

Swift and `swiftc` must be on PATH. Native `gst` is used if installed. The verifier checks `../tmp/smalltalk-runtime/` and then `../../tmp/smalltalk-runtime/` for an extracted runtime. Recreate it if needed:

```powershell
python tools/setup_smalltalk.py
```

Setup requires WSL with an `Ubuntu` distribution on Windows, or `dpkg-deb` and Bash on Linux. It downloads six pinned Debian packages, checks SHA-256 against `tools/smalltalk_runtime.json`, and extracts them into the workspace. It does not install global packages or modify WSL's package database. Initial downloads need internet. Keep the sibling runtime folder for local execution, or rerun setup after copying this project. Archived runtime libraries are for these local exercises; the programs need no network.

## Run one program

From this folder, Swift (replace the filename for another problem):

```text
companion_programs\.build\campus_fare_pass.exe
```

Use compile-then-run on this Windows installation: direct `swift file.swift` execution hits a toolchain JIT symbol-resolution error. The compiled executables and combined verifier run successfully. On Linux/macOS, omit `.exe` and use `./.build/campus_fare_pass`.


For this workspace's Windows/WSL runtime:

```text
wsl -d Ubuntu -- bash ./companion_programs/tools/gst-local.sh -f ./companion_programs/smalltalk/campus_fare_pass.st
```

GNU Smalltalk, when `gst` is installed:

```text
gst -f smalltalk/campus_fare_pass.st
gst -f smalltalk/campus_fare_pass.st --test
```

Append `--test` to test. The verifier resolves absolute paths automatically and is the simplest command. Run each source file in a separate process; their top-level sessions are independent.

## Shared rules

1. **Fare Pass:** integer centavos, nonnegative base. Regular pays 100%; student pays 80%, rounded to the nearest centavo. Negative amounts return `nil`. Enter a base fare in whole centavos: 2000 (PHP 20) produces 2000 and 1600. Input must contain decimal digits only, from 0 through 9223372036854775807; invalid input shows an error and ends the program. Rates are fictional. Swift uses overflow-safe quotient/remainder arithmetic. Smalltalk has arbitrary-size integers; shared numeric tests use signed 64-bit inputs. At an 80% rate, integer inputs cannot produce exact half-centavo ties.
2. **Seat Counter:** capacity is a nonnegative integer; occupied starts at zero. Reserve/cancel return a Boolean. Full reservation and empty cancellation fail without changing state. Negative construction fails; zero capacity is valid. Swift has a private state setter; Smalltalk accesses instance variables through messages. Its public initializer follows an initialization-only convention: valid explicit reinitialization resets the room, while invalid reinitialization is rejected before mutation.
3. **Matcher / inventory:** starts with five sample records. Menu: 1 Register, 2 Search, 3 Inventory, 4 Exit. Register an item name, category and location; blank or whitespace-only fields are rejected without changing the inventory. Arbitrary nonblank categories/locations are allowed. Identical records are allowed because separate found objects can have the same description. Search uses exact case-sensitive category AND location comparison and preserves registration order. For example, umbrella + library finds Blue umbrella and Black umbrella. Inventory lists every item as name | category | location. New records are stored only in memory: exiting resets the inventory to its five samples. No database or file saving is included.

Brief comments identify language constructs. Each file includes its own test mode, which contributes to physical line count. Seat Counter and Matcher menus repeat until 4 (Exit) or end-of-input; invalid menu choices leave state unchanged. Fare performs one calculation per run. End-of-input exits cleanly. Searches use exact case-sensitive text; whitespace is not silently trimmed.

## Interactive examples

- Fare Pass: type `2000` and press Enter. Amounts and results are in centavos.
- Seat Counter: type `1` to reserve, `2` to cancel, `3` for status, or `4` to exit. Capacity remains 2.
- Matcher: choose `1`, then enter `Green cap`, `clothing`, `lobby`. Choose `2` and search for `clothing` / `lobby`; choose `3` to see all six records; choose `4` to exit. To search the initial samples, use umbrella/bottle/stationery and library/canteen/lobby.
- Test mode does not ask for keyboard input.

## Review

The source review and final checks cover both languages. No term-paper analysis, synthesis, language-rating matrix or lessons are included.

## Primary technical references

- [GNU Smalltalk invocation and syntax](https://www.gnu.org/software/smalltalk/manual/gst.html)
- [Swift protocols](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/)
- [Swift closures](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/closures/)
- [Debian GNU Smalltalk package](https://packages.debian.org/bullseye/gnu-smalltalk)

