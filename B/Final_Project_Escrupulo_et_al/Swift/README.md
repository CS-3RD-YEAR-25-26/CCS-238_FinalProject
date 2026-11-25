# Swift Programming

## Overview

This collection contains three Swift programs developed for the CCS 238 Programming Languages comparative project: a recursive merge sort, a student grade management system, and a word frequency analyzer. They demonstrate arrays, functions, recursion, classes, static typing, optional values, error handling, control structures, and text processing. The programs use the same example inputs and expected functional results as the group's Python baseline for comparison with Simula 67 and Smalltalk.

## Programming Language

All three programs are written in Swift. The implementations demonstrate:

- `Int`, `Double`, and `String` for integer, numerical, and text values.
- Arrays, such as `[Int]`, for storing collections of values.
- `var` and `let` for declaring variables and constants.
- `func` for defining reusable functions, including recursive sorting and grade calculations.
- `class` for organizing student records and their operations.
- Conditional statements and loops for comparisons, validation, and iteration.
- Optional types, such as `Double?`, and `nil` for representing missing values, including an unavailable grade average.
- Error throwing and handling for invalid operations in the student grade management system.
- Dictionaries and default-value subscripts, such as `wordCounts[word, default: 0] += 1`, for counting word occurrences.
- Sorting closures and `print` for ordering and displaying results.

## Programs Included

### Recursive Merge Sort

**File:** `recursive_merge_sort.swift`

Sorts an array of eight integers in ascending order. The program recursively divides the array into smaller halves, sorts each half, and merges them back together. It prints the original array, comparison and remaining-element messages, and the final sorted array.

Initial values: `12, 31, 4, 3, 9, 5, 8, 24`.

### Student Grade Management System

**File:** `student_grade.swift`

Stores student IDs, names, and grades, calculates average grades, and displays each student's academic status. The program uses 60.0 as the passing threshold and displays `N/A` and `No grades` when a student has no recorded grades. It also includes validation for grade ranges, blank student information, duplicate IDs, and missing student records.

### Word Frequency Analyzer

**File:** `word_frequency.swift`

Analyzes the fixed text `Hello, world! hello.` It converts words to lowercase, separates words from punctuation, and uses a dictionary to count occurrences. The program displays word frequencies alphabetically, the total and unique word counts, and a summary of the most frequent words.

## Input Data

The examples use data defined in the source code rather than requesting interactive input:

- **Merge sort:** `12, 31, 4, 3, 9, 5, 8, 24`
- **Student system:** S1 Ari (80.0, 90.0); S2 Bea (55.0, 65.0); S3 Cal (45.0, 50.0); S4 Dee (no grades)
- **Word analyzer:** `Hello, world! hello.`

## Program Output

The programs print merge sort progress and the sorted array, a student grade report, and a word frequency report with summary counts. All three programs were reported as successfully run in OnlineGDB using the sample inputs.

The expected results include:

**Recursive Merge Sort**

```text
Sorted array is: [3, 4, 5, 8, 9, 12, 24, 31]
```

**Student Grade Management System**

```text
Student grade report:
S1 | Ari | Grades: 80, 90 | Average: 85.0 | Status: Pass
S2 | Bea | Grades: 55, 65 | Average: 60.0 | Status: Pass
S3 | Cal | Grades: 45, 50 | Average: 47.5 | Status: Fail
S4 | Dee | Grades: None | Average: N/A | Status: No grades
```

**Word Frequency Analyzer**

```text
Paragraph: Hello, world! hello.

Word frequencies (alphabetical):
hello: 2
world: 1

Text summary:
Total words: 3
Unique words: 2
Most frequent words: [('hello', 2), ('world', 1)]
```

## Compiler and Testing Information

- **Language:** Swift
- **Compiler:** Swift compiler provided by OnlineGDB
- **Compiler version:** Swift 5.7.x range (conditional compilation checks indicated at least Swift 5.7 and below Swift 5.8; exact patch version not verified)
- **Environment:** OnlineGDB, web browser
- **Test status:** All three programs were run successfully with the provided sample inputs, according to the original testing record.

> OnlineGDB may update its compiler. The compiler version available during future runs may differ from the version used for the original tests.

## How to Run

To run one of the programs using the OnlineGDB Swift compiler:

1. Open the [OnlineGDB Swift compiler](https://www.onlinegdb.com/online_swift_compiler).
2. Make sure Swift is selected in the Language dropdown.
3. Open the `.swift` source file for the program you want to run and copy its complete code. If accessing the file through GitHub, you may use the Raw view to copy the source.
4. Paste the code into the OnlineGDB editor, replacing the existing sample code.
5. Click the Run button at the top of the page.
6. Read the results in the console below the editor. If an error occurs, check the compiler messages and make sure the complete source code was copied.
7. Compare the results with the expected output in this README.

Run each program separately by replacing the editor contents with its source code before clicking Run. No interactive input or local Swift installation is required for these examples.
