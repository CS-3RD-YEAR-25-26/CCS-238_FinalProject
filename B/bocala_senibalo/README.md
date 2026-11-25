# FORTRAN vs. Julia: Comparative Programming Languages Project

**Project:** Static Rules vs. Dynamic Tools: A Comparative Analysis of FORTRAN (1957) and Julia (2012)  
**Course:** Programming Languages  
**Applications:** Student Grade Evaluator, Descriptive Statistics Calculator, and StudentWise Budget Manager

## Overview

This project explores the design and programming practices of **FORTRAN** and **Julia** through three comparable, **terminal-based** applications. Each system is implemented in both languages with broadly equivalent features so their syntax, data structures, input validation, program organization, and numerical operations can be examined side by side.

**Language clarification:** FORTRAN originated in 1957, but the implementations in this repository use **modern Fortran** features, including modules, derived types, free-form source code, and allocatable arrays. The Julia implementations use contemporary Julia syntax. The dates in the project title identify the languages' historical origins; they do **not** mean the FORTRAN programs use only 1957-era syntax.

All six applications run in a terminal. **No GUI frameworks, database, or third-party Julia packages are required.**

## Project Structure

Organize the final source files as follows:

```text
FORTRAN-vs-Julia/
├── README.md
├── system1_grade_evaluator/
│   ├── fortran/
│   │   └── grade_evaluator.f90
│   └── julia/
│       └── grade_evaluator.jl
├── system2_descriptive_statistics/
│   ├── fortran/
│   │   ├── parser.f90
│   │   └── dataset.csv
│   └── julia/
│       ├── parser.jl
│       └── dataset.csv
└── system3_studentwise/
    ├── fortran/
    │   ├── budget.f90
    │   └── main.f90
    └── julia/
        ├── budget.jl
        └── main.jl
```

The folders above are the **recommended submission layout**. Place a copy of each final source file in its corresponding folder. If a downloaded source file has a version suffix such as `(8)` in its name, rename that copy to the canonical filename shown above.

The Statistics Calculator expects `dataset.csv` in the **current working directory**. Keeping one copy alongside each language's parser makes the commands below work without changing the source code.

## Requirements

- **GNU Fortran (`gfortran`)** to compile `.f90` files.
- **Julia** to run `.jl` files.
- A terminal (for example, the VS Code integrated terminal or macOS Terminal).
- A plain-text editor such as Visual Studio Code.

Check your installed tools:

```bash
gfortran --version
julia --version
```

On macOS, GNU Fortran is commonly installed through the GCC package; Julia can be installed from the official Julia distribution. The code uses the Julia standard-library modules `Printf` and `Dates`, so no `Pkg.add(...)` steps are needed.

## System 1 — Student Grade Evaluator

### Features

- Accepts a student's name (uses `Student` if left blank or entered as only whitespace).
- Accepts **five whole-number grades**, each from **60 to 100**.
- Calculates the **average, highest grade, and lowest grade**.
- Identifies the **best- and worst-performing subjects**, including ties.
- Displays a descriptive remark for each grade and for the overall average.
- Marks the student **PASSED** when the average is **75 or above**; otherwise **FAILED**.
- Allows multiple students to be evaluated in one run.

Subjects: Mathematics, English, Science, Filipino, and Araling Panlipunan.

### Run the FORTRAN version

From the project root:

```bash
cd system1_grade_evaluator/fortran
gfortran grade_evaluator.f90 -o grade_evaluator
./grade_evaluator
```

### Run the Julia version

From the project root (in a new terminal, or after returning to the root):

```bash
cd system1_grade_evaluator/julia
julia grade_evaluator.jl
```

### Example interaction

```text
Enter student name: Alex
Enter grade for Mathematics: 95
Enter grade for English: 90
Enter grade for Science: 85
Enter grade for Filipino: 80
Enter grade for Araling Panlipunan: 75

Average Grade : 85.00
Final Status  : PASSED
```

The complete terminal report also includes each subject's remark, highest/lowest grade, best/worst subjects, and overall remark.

## System 2 — Descriptive Statistics Calculator

### Features

- Reads numeric data from **`dataset.csv`**, with **one number per line**.
- Uses a **two-pass reading approach**: first counts valid values, then allocates and fills an array.
- Skips blank lines and reports many nonnumeric lines.
- Calculates the **mean, median, mode, and sample standard deviation**.
- Displays the total number of processed values and statistics formatted to two decimal places.
- Sorts a copy of the data to calculate the median and mode.

### Dataset format

Create or edit `dataset.csv` with one numeric value per line:

```text
10
20
20
30
40
```

This is a **single-column numeric dataset**, not a general-purpose parser for CSV tables with multiple comma-separated columns or headers. Avoid entries such as `10,20` on one line: the FORTRAN and Julia parsers can interpret them differently.

### Run the FORTRAN version

From the project root:

```bash
cd system2_descriptive_statistics/fortran
gfortran parser.f90 -o statistics
./statistics
```

Ensure `dataset.csv` is inside the same folder and run the executable **while that folder is the current working directory**.

### Run the Julia version

From the project root:

```bash
cd system2_descriptive_statistics/julia
julia parser.jl
```

Ensure this folder also contains `dataset.csv`.

### Expected results for the example dataset

| Statistic | Value |
|---|---:|
| Valid data points | 5 |
| Mean | 24.00 |
| Median | 20.00 |
| Mode | 20.00 |
| Sample standard deviation | 11.40 |

**Important edge cases:** For a dataset with only one valid value, **sample** standard deviation is mathematically undefined; the provided FORTRAN implementation does not guard against division by `n - 1 = 0`, while the Julia implementation may display `0.00` as a fallback. The mode routine also returns one candidate even when all values occur once, and it does not list every tied mode. Use datasets with **at least two numeric values** and preferably one clearly most-frequent value for comparable demonstrations.

## System 3 — StudentWise Budget Manager

### Features

StudentWise is a terminal-based personal budget tracker that allows the user to:

1. Set or update a **weekly allowance**.
2. Record an expense using a default or custom category.
3. View expense history.
4. View a budget summary and remaining balance.
5. Set or update a savings goal.
6. Check savings progress.
7. Add or remove savings and view savings transaction history.
8. Exit the application.

The remaining balance is calculated as:

```text
Remaining balance = Weekly allowance - Total expenses - Saved amount
```

The system validates amounts, blocks expenses that exceed the available balance, and restricts savings deposits based on the available balance and remaining savings goal. Monetary input is recorded as **whole-number Philippine pesos (PHP)**.

### Record limits

- Maximum **100 expense records**.
- Maximum **100 savings history records**.
- Expense category names: up to **40 characters**.

Both programs enforce the 100-record limits. In the FORTRAN version, the `BudgetState` derived type contains fixed-size arrays. In the Julia version, `Vector{Expense}` and the savings-history vector start empty and grow through `push!()` until the program's limits are reached. These are implementation choices; modern Fortran also supports allocatable arrays.

### Run the FORTRAN version

**Both source files are required.** Compile `budget.f90` before `main.f90` because the main program uses `budget_module`:

```bash
cd system3_studentwise/fortran
gfortran budget.f90 main.f90 -o studentwise
./studentwise
```

Do **not** compile only `main.f90`; it depends on the module defined in `budget.f90`.

### Run the Julia version

Keep `main.jl` and `budget.jl` in the **same folder**:

```bash
cd system3_studentwise/julia
julia main.jl
```

`main.jl` loads `budget.jl` using:

```julia
include(joinpath(@__DIR__, "budget.jl"))
```

### Example scenario

```text
Weekly allowance : PHP 1000
Expense (Food)   : PHP 150
Savings goal     : PHP 500
Savings added    : PHP 200
Remaining balance: PHP 650
Savings progress : 40.00%
```

These figures illustrate the calculations; the terminal application presents them across its menu screens.

**Data persistence:** StudentWise stores its expenses and savings history **in memory only**. Closing and restarting either version creates a new budget; the programs do not currently save transactions to a database or permanent file.

## Main Language Differences Demonstrated

| Topic | FORTRAN implementation | Julia implementation |
|---|---|---|
| Variable typing | Explicit declarations such as `integer` and `real(real64)` | Values have runtime types; optional argument annotations such as `::Int` |
| Input validation | `READ` with `IOSTAT` | `readline()` with `tryparse()` |
| Array indexing | `grades(1)` | `grades[1]` |
| Numeric arrays | Native element-wise array arithmetic | Broadcasting operators such as `.-` and `.^` |
| Multiple computed results | Subroutine arguments with `intent(out)` | Returned tuple |
| Custom records | `type :: Expense` | `struct Expense` |
| Accessing fields | `budget%amount`-style syntax | `budget.amount`-style syntax |
| Updating a budget | `intent(inout)` arguments | Mutating functions conventionally named with `!` |
| File organization | `module` and `use` | Separate source files using `include()` |

These differences describe **the supplied implementations**. They do not, by themselves, establish that either language is universally faster, more memory-efficient, or more reliable. Performance comparisons require controlled measurements.

## Troubleshooting

**`gfortran: command not found`** — Install GNU Fortran and verify it is on your terminal's `PATH`.

**`julia: command not found`** — Install Julia and make the `julia` executable accessible from the terminal.

**`Error: Could not open file` in System 2** — Confirm `dataset.csv` exists and that your current working directory is the folder containing it. Check with `pwd` and `ls` on macOS.

**Module or linker errors in System 3 FORTRAN** — Compile both files together in this order: `gfortran budget.f90 main.f90 -o studentwise`.

**`could not open file ... budget.jl` in System 3 Julia** — Put `budget.jl` and `main.jl` together, and run the correct `main.jl`.

**Invalid input** — System 1 requires whole-number grades from 60 through 100. System 3 monetary amounts are entered as whole numbers. System 2 expects numeric data, one value per line.

## Notes for Reproducibility

- Run each version using equivalent inputs when comparing behavior.
- Use the **same `dataset.csv` contents** for the two System 2 implementations.
- Record the operating system, compiler version, and Julia version used for a demonstration or benchmark.
- Source files are intended to be run in the **terminal**, including the VS Code integrated terminal.
- FORTRAN's origin year is 1957, but these source files use features added by later Fortran standards.

## Academic Context

These six implementations accompany a comparative programming-languages project. They are intended to illustrate language features and program design; any evaluation of readability, writability, reliability, efficiency, or maintainability should be supported by the project's documented methods and observations.
