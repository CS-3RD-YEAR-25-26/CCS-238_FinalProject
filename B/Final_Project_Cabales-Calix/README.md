# Beyond the Match: A Comparative Analysis of String Pattern Matching and Grammar Design in SNOBOL4 (1967) and Raku (2015)

**Course:** CCS 238 - Programming Languages

**Project directory:** `B/Final_Project_Cabales-Calix/`

This project compares how SNOBOL4 and Raku express the same or closely related programming tasks. Its companion programs cover syntax, names and binding, data types, control flow, abstraction, modularity, pattern matching, recursive patterns, grammars, and semantic actions.

There are **32 paired examples and 64 runnable programs**: 32 SNOBOL4 programs and 32 Raku entry points. Raku example 10.1.20 consists of an entry point and a separate local module. Each program uses values written into its source and prints its results; no interactive input, database, or external data files are required. The account examples are small demonstrations of language concepts.

## Contents

- [Repository structure](#repository-structure)
- [Runtime requirements](#runtime-requirements)
- [Windows setup](#windows-setup)
  - [SNOBOL4 setup](#snobol4-setup)
  - [Raku setup](#raku-setup)
- [Run the companion programs](#run-the-companion-programs)
- [Examples and expected output](#examples-and-expected-output)
- [Companion program index](#companion-program-index)
- [Troubleshooting](#troubleshooting)
- [Working with the source files](#working-with-the-source-files)
- [Academic context and assistance](#academic-context-and-assistance)

## Repository structure

The following tree shows this project's program and setup files, relative to `B/Final_Project_Cabales-Calix/`:

```text
Final_Project_Cabales-Calix/
|-- README.md                  # Setup, commands, expected output, and source index
|-- requirements.txt           # Python requirements file; no package entries needed
|-- snobol4/                   # 32 programs: 10_1_1.sno through 10_1_32.sno
`-- raku/
    |-- 10_1_*.raku            # 31 programs: numbers 1-19 and 21-32
    `-- 10_1_20/
        |-- main.raku          # Entry point for example 10.1.20
        `-- Pricing.rakumod    # Local module exporting the total routine
```

The wildcard in the tree summarizes the numbered Raku files. The [program index](#companion-program-index) links to every source file.

## Runtime requirements

The complete set of 64 programs was verified on Windows with these versions:

| Language | Runtime implementation | Verified version | Source files | Version command |
| --- | --- | --- | --- | --- |
| SNOBOL4 | CSNOBOL4, including SNOBOL4B extensions | 2.3.5 | `.sno` | `snobol4 -v` |
| Raku | Rakudo on MoarVM | 2026.11, implementing Raku 6.d | `.raku`, `.rakumod` | `raku --version` |

These are verified versions, not claimed minimum versions. Install both runtimes to compare every pair, or install just the runtime for the language you want to run. The Windows archives below contain compiled binaries, so building the runtimes from source is unnecessary. See the official [CSNOBOL4 release page](https://www.regressive.org/snobol4/csnobol4/curr/) and [Rakudo downloads](https://www.rakudo.org/downloads).

For the Windows instructions, use:

- A Windows 10 or Windows 11 PC with x64 support.
- Windows PowerShell 5.1 or PowerShell 7.
- Internet access to download the runtimes.
- Windows `tar.exe` for the SNOBOL4 archive; the commands use its full path under `%SystemRoot%\System32`. Raku's ZIP is extracted with PowerShell's `Expand-Archive`.

The programs use built-in language features. `Pricing.rakumod` is included in the project, and no third-party Raku modules or SNOBOL4 libraries need to be installed.

[requirements.txt](requirements.txt) follows the conventional pip requirements format and intentionally contains only comments: this project has **no Python package dependencies**. Python, pip, and a Python virtual environment are not needed to run the companion programs. `pip install -r requirements.txt` would install no packages; install the language runtimes using the steps below.

## Windows setup

The two procedures are independent. Run each procedure's steps in order in the same PowerShell window until it tells you to reopen the terminal. The commands install the archives under your own `%LOCALAPPDATA%\CCS238\runtimes` directory and save downloads under `%LOCALAPPDATA%\CCS238\downloads`; administrator access is not required.

Keep each extracted runtime's complete directory tree together. The commands use specific archive versions so the paths are reproducible. If you choose another release, update both its download filename and its extracted directory name.

### SNOBOL4 setup

**1. Download the Windows binary archive.** Use [windows-2.3.5.tar.gz](https://ftp.regressive.org/snobol4/Win10/windows-2.3.5.tar.gz), listed in the official [Windows download directory](https://ftp.regressive.org/snobol4/Win10/). Run:

```powershell
$snobolDownloadDir = Join-Path $env:LOCALAPPDATA 'CCS238\downloads'
New-Item -ItemType Directory -Force -Path $snobolDownloadDir | Out-Null
$snobolArchive = Join-Path $snobolDownloadDir 'windows-2.3.5.tar.gz'
Invoke-WebRequest -UseBasicParsing -Uri 'https://ftp.regressive.org/snobol4/Win10/windows-2.3.5.tar.gz' -OutFile $snobolArchive
```

**2. Extract the archive into its installation location.** The archive already contains `SNOBOL4/2.3.5/`; extract it into the runtime directory:

```powershell
$snobolRuntimeDir = Join-Path $env:LOCALAPPDATA 'CCS238\runtimes'
New-Item -ItemType Directory -Force -Path $snobolRuntimeDir | Out-Null
& "$env:SystemRoot\System32\tar.exe" -xzf $snobolArchive -C $snobolRuntimeDir
if ($LASTEXITCODE -ne 0) { throw 'SNOBOL4 archive extraction failed.' }
$snobolBase = Join-Path $snobolRuntimeDir 'SNOBOL4'
$snobolBin = Join-Path $snobolBase '2.3.5\bin'
Test-Path -LiteralPath (Join-Path $snobolBin 'snobol4.exe')
```

The last command must print `True`. This archive installation has no setup wizard: extraction places the executable and its libraries on the PC.

**3. Configure the current terminal.** Add the executable directory to `PATH` and set the library base directory:

```powershell
$env:Path = "$snobolBin;$env:Path"
$env:SNOLIB = $snobolBase
```

`SNOLIB` points to `...\runtimes\SNOBOL4`, the directory **above** `2.3.5`. The interpreter builds its versioned library search paths from this base, as described in the [CSNOBOL4 manual](https://www.regressive.org/snobol4/csnobol4/curr/doc/snobol4.1.html). An existing `SNOPATH` setting overrides this default library search behavior.

**4. Save the settings for future terminals.** This adds the executable directory to your user `PATH` if it is absent, preserves the other user entries, and saves `SNOLIB`:

```powershell
$snobolUserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$snobolPathEntries = @($snobolUserPath -split ';' | Where-Object { $_ })
if ($snobolPathEntries -notcontains $snobolBin) {
    [Environment]::SetEnvironmentVariable('Path', (($snobolPathEntries + $snobolBin) -join ';'), 'User')
}
[Environment]::SetEnvironmentVariable('SNOLIB', $snobolBase, 'User')
```

**5. Verify the installation.** In the current terminal, run:

```powershell
Get-Command snobol4 | Select-Object Source
snobol4 -v
snobol4 -z
```

The executable path should end in `CCS238\runtimes\SNOBOL4\2.3.5\bin\snobol4.exe`, the version should report `2.3.5`, and the search list should include the extracted `2.3.5\lib` directory. Close and reopen the terminal, then repeat these checks to confirm the saved settings work. Restart VS Code or Windows Terminal as well if its new terminals still inherit an older environment.

### Raku setup

**1. Download the Rakudo Windows ZIP.** Use [rakudo-moar-2026.11-01-win-x86_64-msvc.zip](https://www.rakudo.org/dl/rakudo/rakudo-moar-2026.11-01-win-x86_64-msvc.zip) from the official [Rakudo downloads](https://www.rakudo.org/downloads). This procedure uses the portable ZIP distribution:

```powershell
$rakuDownloadDir = Join-Path $env:LOCALAPPDATA 'CCS238\downloads'
New-Item -ItemType Directory -Force -Path $rakuDownloadDir | Out-Null
$rakuArchive = Join-Path $rakuDownloadDir 'rakudo-moar-2026.11-01-win-x86_64-msvc.zip'
Invoke-WebRequest -UseBasicParsing -Uri 'https://www.rakudo.org/dl/rakudo/rakudo-moar-2026.11-01-win-x86_64-msvc.zip' -OutFile $rakuArchive
```

**2. Extract the ZIP into its installation location.** The ZIP contains its own versioned top-level directory:

```powershell
$rakuRuntimeDir = Join-Path $env:LOCALAPPDATA 'CCS238\runtimes'
New-Item -ItemType Directory -Force -Path $rakuRuntimeDir | Out-Null
Expand-Archive -LiteralPath $rakuArchive -DestinationPath $rakuRuntimeDir -Force
$rakuInstallDir = Join-Path $rakuRuntimeDir 'rakudo-moar-2026.11-01-win-x86_64-msvc'
$rakuBin = Join-Path $rakuInstallDir 'bin'
$rakuSiteBin = Join-Path $rakuInstallDir 'share\perl6\site\bin'
Test-Path -LiteralPath (Join-Path $rakuBin 'raku.exe')
```

The last command must print `True`. The ZIP provides Rakudo and its runtime components, along with the `zef` module manager; no separate MoarVM or NQP installation is needed.

**3. Configure the current terminal.** Add both executable directories:

```powershell
$env:Path = "$rakuBin;$rakuSiteBin;$env:Path"
```

`bin` contains `raku`; `share\perl6\site\bin` contains Raku scripts such as `zef`. These paths follow the package's [Windows instructions](https://raw.githubusercontent.com/rakudo/rakudo/refs/heads/main/tools/build/binary-release/assets/Windows/README.txt). No `zef install` command is needed for this project.

**4. Save the PATH entries for future terminals.** Preserve your existing user `PATH` and add each directory only if it is absent:

```powershell
$rakuUserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$rakuPathEntries = @($rakuUserPath -split ';' | Where-Object { $_ })
foreach ($rakuPathEntry in @($rakuBin, $rakuSiteBin)) {
    if ($rakuPathEntries -notcontains $rakuPathEntry) {
        $rakuPathEntries += $rakuPathEntry
    }
}
[Environment]::SetEnvironmentVariable('Path', ($rakuPathEntries -join ';'), 'User')
```

**5. Verify the installation.** In the current terminal, run:

```powershell
Get-Command raku | Select-Object Source
raku --version
raku -e 'say 6 * 7'
```

The executable should come from the extracted `rakudo-moar-2026.11-01-win-x86_64-msvc\bin` directory. The version should report Rakudo `2026.11`, and the final command should print `42`. Close and reopen the terminal, then repeat the checks. Restart the application hosting your terminal if it still uses an older environment.

If Unicode output appears garbled, apply the package's UTF-8 console configuration in the affected PowerShell window:

```powershell
$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding
```

## Run the companion programs

First obtain the repository by cloning it or downloading and extracting its ZIP from GitHub. Open PowerShell in the repository root, `CCS-238_FinalProject`, and enter the project folder:

```powershell
Set-Location '.\B\Final_Project_Cabales-Calix'
```

**All commands below assume this project folder is the current directory.** Confirm that `Get-ChildItem` shows `snobol4`, `raku`, and this README. If your terminal is already here, skip `Set-Location`.

### Run one pair

```powershell
snobol4 -b -U '.\snobol4\10_1_1.sno'
raku '.\raku\10_1_1.raku'
```

Each command prints `dog bat`. Substitute another source path from the index to run a different example. The filename `10_1_1` corresponds to Appendix 10.1.1; numbering continues through 10.1.32. For SNOBOL4, `-b` disables the banner and `-U` disables standard I/O buffering. See the [CSNOBOL4 command-line reference](https://www.regressive.org/snobol4/csnobol4/curr/doc/snobol4cmd.1.html).

### Run the Raku module example (10.1.20)

The entry point imports the included `Pricing` module. Supply its directory with `-I`:

```powershell
snobol4 -b -U '.\snobol4\10_1_20.sno'
raku -I '.\raku\10_1_20' '.\raku\10_1_20\main.raku'
```

Both print `12`. If your terminal is inside `raku/10_1_20/`, the equivalent Raku command is `raku -I. main.raku`. Run `main.raku` as the entry point; `Pricing.rakumod` supplies the reusable routine.

### Run all 32 pairs

This loop runs examples in numerical order and handles Raku example 10.1.20 separately:

```powershell
foreach ($example in 1..32) {
    Write-Host "SNOBOL4 - 10.1.$example"
    snobol4 -b -U ".\snobol4\10_1_$example.sno"
    if ($LASTEXITCODE -ne 0) { throw "SNOBOL4 example $example failed." }

    Write-Host "Raku - 10.1.$example"
    if ($example -eq 20) {
        raku -I '.\raku\10_1_20' '.\raku\10_1_20\main.raku'
    } else {
        raku ".\raku\10_1_$example.raku"
    }
    if ($LASTEXITCODE -ne 0) { throw "Raku example $example failed." }
}
```

## Examples and expected output

These results come from the current source files. In the tables, `<br>` separates successive output lines.

| Example | Demonstration | Output from each language |
| --- | --- | --- |
| 10.1.1 | Replace `cat` with `dog` in `cat bat` | `dog bat` |
| 10.1.3 | Recognize the numeric string `123` | `valid` |
| 10.1.14 | Iterate from 1 through 3 | `1`<br>`2`<br>`3` |
| 10.1.15 | Calculate the factorial of 4 | `24` |
| 10.1.20 | Calculate `total(3, 4)` | `12` |
| 10.1.27 | Capture the number from `ID=69` | `69` |
| 10.1.28 | Replace both occurrences in `cat cat` | `dog dog` |
| 10.1.30 | Parse `age=42` | `age:42` |
| 10.1.31 | Evaluate the command `MUL(6,7)` | `Result: 42` |
| 10.1.32 | Deposit 2 into an account starting at 5 | `7` |

Some examples intentionally produce different output because they demonstrate different language behavior or introspection facilities:

| Example | SNOBOL4 output | Raku output | Explanation |
| --- | --- | --- | --- |
| 10.1.6 | `2`<br>`1` | `1`<br>`1` | SNOBOL4's active function-local binding contrasts with Raku's lexical name resolution. |
| 10.1.7 | `STRING`<br>`INTEGER`<br>`REAL`<br>`TRUE` | `Str`<br>`Int`<br>`Num`<br>`Rat`<br>`True` | The examples expose each language's type names; Raku also demonstrates an exact rational value. |
| 10.1.9 | `cat` | `42` | The SNOBOL4 variable accepts a string; Raku catches a rejected assignment to an `Int` variable and retains 42. |
| 10.1.10 | `2`<br>`yes` | `8`<br>`yes` | The expression `8 / 2 * 2` groups differently in the two languages. |
| 10.1.12 | `15`<br>`INTEGER` | `15`<br>`Int` | Both compute 15, then report the stored value's language-specific type name. |
| 10.1.24 | `POINT`<br>`X` | `Point`<br>`2` | SNOBOL4 reports the record type and first field name; Raku reports the class name and attribute count. |

## Companion program index

All links are relative to this README's directory, `B/Final_Project_Cabales-Calix/`.

| Appendix | Programming concept | SNOBOL4 source | Raku source |
| --- | --- | --- | --- |
| 10.1.1 | Dynamic Semantics | [10_1_1.sno](snobol4/10_1_1.sno) | [10_1_1.raku](raku/10_1_1.raku) |
| 10.1.2 | Lexical and Syntactic Analysis | [10_1_2.sno](snobol4/10_1_2.sno) | [10_1_2.raku](raku/10_1_2.raku) |
| 10.1.3 | Parsing Techniques | [10_1_3.sno](snobol4/10_1_3.sno) | [10_1_3.raku](raku/10_1_3.raku) |
| 10.1.4 | Name Resolution: Names, Variables, and Naming Conventions | [10_1_4.sno](snobol4/10_1_4.sno) | [10_1_4.raku](raku/10_1_4.raku) |
| 10.1.5 | Binding | [10_1_5.sno](snobol4/10_1_5.sno) | [10_1_5.raku](raku/10_1_5.raku) |
| 10.1.6 | Scope, Lifetime, and Reference Environments | [10_1_6.sno](snobol4/10_1_6.sno) | [10_1_6.raku](raku/10_1_6.raku) |
| 10.1.7 | Primitive and Composite Data Types | [10_1_7.sno](snobol4/10_1_7.sno) | [10_1_7.raku](raku/10_1_7.raku) |
| 10.1.8 | Type Checking | [10_1_8.sno](snobol4/10_1_8.sno) | [10_1_8.raku](raku/10_1_8.raku) |
| 10.1.9 | Strong Typing and Type Safety | [10_1_9.sno](snobol4/10_1_9.sno) | [10_1_9.raku](raku/10_1_9.raku) |
| 10.1.10 | Arithmetic and Boolean Expressions | [10_1_10.sno](snobol4/10_1_10.sno) | [10_1_10.raku](raku/10_1_10.raku) |
| 10.1.11 | Operator Overloading | [10_1_11.sno](snobol4/10_1_11.sno) | [10_1_11.raku](raku/10_1_11.raku) |
| 10.1.12 | Type Conversions | [10_1_12.sno](snobol4/10_1_12.sno) | [10_1_12.raku](raku/10_1_12.raku) |
| 10.1.13 | Programming Statements (Selection) | [10_1_13.sno](snobol4/10_1_13.sno) | [10_1_13.raku](raku/10_1_13.raku) |
| 10.1.14 | Programming Statements (Iteration) | [10_1_14.sno](snobol4/10_1_14.sno) | [10_1_14.raku](raku/10_1_14.raku) |
| 10.1.15 | Programming Statements (Recursion) | [10_1_15.sno](snobol4/10_1_15.sno) | [10_1_15.raku](raku/10_1_15.raku) |
| 10.1.16 | Programming Statements (Assignment) | [10_1_16.sno](snobol4/10_1_16.sno) | [10_1_16.raku](raku/10_1_16.raku) |
| 10.1.17 | Statement-Level Control Structures | [10_1_17.sno](snobol4/10_1_17.sno) | [10_1_17.raku](raku/10_1_17.raku) |
| 10.1.18 | Abstract Data Types | [10_1_18.sno](snobol4/10_1_18.sno) | [10_1_18.raku](raku/10_1_18.raku) |
| 10.1.19 | Encapsulation Constructs | [10_1_19.sno](snobol4/10_1_19.sno) | [10_1_19.raku](raku/10_1_19.raku) |
| 10.1.20 | Modularity and Program Refactoring | [10_1_20.sno](snobol4/10_1_20.sno) | [main.raku](raku/10_1_20/main.raku), [Pricing.rakumod](raku/10_1_20/Pricing.rakumod) |
| 10.1.21 | Object-Oriented Features | [10_1_21.sno](snobol4/10_1_21.sno) | [10_1_21.raku](raku/10_1_21.raku) |
| 10.1.22 | Inheritance vs. Composition | [10_1_22.sno](snobol4/10_1_22.sno) | [10_1_22.raku](raku/10_1_22.raku) |
| 10.1.23 | Dynamic Binding and Polymorphism | [10_1_23.sno](snobol4/10_1_23.sno) | [10_1_23.raku](raku/10_1_23.raku) |
| 10.1.24 | Reflection | [10_1_24.sno](snobol4/10_1_24.sno) | [10_1_24.raku](raku/10_1_24.raku) |
| 10.1.25 | Pattern Matching, Character Classes, and Anchoring | [10_1_25.sno](snobol4/10_1_25.sno) | [10_1_25.raku](raku/10_1_25.raku) |
| 10.1.26 | Pattern Composition, Alternation, and Backtracking | [10_1_26.sno](snobol4/10_1_26.sno) | [10_1_26.raku](raku/10_1_26.raku) |
| 10.1.27 | Substring Capturing and Assignment | [10_1_27.sno](snobol4/10_1_27.sno) | [10_1_27.raku](raku/10_1_27.raku) |
| 10.1.28 | Search-and-Replace Operations | [10_1_28.sno](snobol4/10_1_28.sno) | [10_1_28.raku](raku/10_1_28.raku) |
| 10.1.29 | Recursive Patterns and Context-Free Recognition | [10_1_29.sno](snobol4/10_1_29.sno) | [10_1_29.raku](raku/10_1_29.raku) |
| 10.1.30 | Grammars, Structured Parsing, and Semantic Actions | [10_1_30.sno](snobol4/10_1_30.sno) | [10_1_30.raku](raku/10_1_30.raku) |
| 10.1.31 | Scenario 1: String Pattern Matching and Grammars | [10_1_31.sno](snobol4/10_1_31.sno) | [10_1_31.raku](raku/10_1_31.raku) |
| 10.1.32 | Scenario 2: Account-Management System | [10_1_32.sno](snobol4/10_1_32.sno) | [10_1_32.raku](raku/10_1_32.raku) |

## Troubleshooting

| Problem | What to check |
| --- | --- |
| `snobol4` or `raku` is not recognized | Repeat that runtime's current-terminal PATH step, or reopen the terminal after saving the user settings. `Get-Command snobol4 -All` or `Get-Command raku -All` reveals other installations taking precedence. |
| A download command fails | Open the linked official archive in your browser, save it locally, and set `$snobolArchive` or `$rakuArchive` to its full path before continuing at extraction. |
| `tar.exe` cannot be found | Confirm that `Test-Path "$env:SystemRoot\System32\tar.exe"` prints `True`. If unavailable, use an archive tool supporting `.tar.gz`; extract the gzip layer and then the contained tar, keeping `SNOBOL4/2.3.5/` intact under the runtime directory. |
| The executable check prints `False` | Check that the download is the Windows binary archive and that extraction created the directory layout shown in the setup steps. Avoid adding another nested copy of the archive's top-level folder. |
| Raku reports `Could not find Pricing` | Run the documented `raku -I ... main.raku` command, with `-I` pointing to the directory containing `Pricing.rakumod`. |
| A source file cannot be opened | Check the working directory. Commands here run from `B/Final_Project_Cabales-Calix/`. From the repository root, prefix source and module paths with `B/Final_Project_Cabales-Calix/`. |
| SNOBOL4 cannot find an included library | Check `$env:SNOLIB` and `snobol4 -z`; the base is `...\runtimes\SNOBOL4`, above the version directory. Also check whether a pre-existing `SNOPATH` overrides it. |
| Raku output contains garbled Unicode | Use the UTF-8 PowerShell configuration in the Raku setup section, and keep the source files saved as UTF-8. |

## Working with the source files

Read the comments at the top of each program for the language constructs being demonstrated. To try another input, edit the sample literal in that program and rerun it; these examples do not accept command-line input parameters.

Preserve SNOBOL4's source layout: labels and comment markers begin in column one, while unlabeled statements begin with whitespace. Keep Raku files encoded as UTF-8, particularly the custom `§` operator in example 10.1.11. Keep `main.raku` and `Pricing.rakumod` together in `raku/10_1_20/`.

An editor with SNOBOL4 and Raku syntax support is useful but optional. Execution takes place through the runtime commands above.

## Academic context and assistance

These companion programs support a comparative programming-language analysis for CCS 238. SNOBOL4 demonstrates pattern-oriented and procedural techniques; Raku demonstrates structured control flow, classes, modules, and grammar-based parsing. The numbered pairs illustrate how each language expresses a concept, including cases where the approaches or results differ.

ChatGPT Plus and OpenAI Codex assisted with code review, source-file organization, documentation, and related project preparation.
