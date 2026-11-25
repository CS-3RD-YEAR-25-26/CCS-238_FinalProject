# Simula 67 Programming 

## Overview

This collection contains three Simula 67 programs: a recursive merge sort, a student grade management system, and a word frequency analyzer. They demonstrate arrays, procedures, recursion, classes, object references, control structures, text processing, and output routines.

## Programming Language

All three programs are written in Simula 67. The source uses:

- `INTEGER ARRAY` and `REAL ARRAY` to store integer values and student grades.
- `PROCEDURE` to define reusable operations, including the sorting routines and student grade operations.
- `BEGIN ... END` to group declarations and statements into blocks.
- `FOR ... STEP ... UNTIL ... DO` and `WHILE ... DO` for iteration through arrays, records, and text.
- `IF ... THEN ... ELSE` to select actions based on comparisons and other conditions.
- `//` for integer division when calculating the merge sort midpoint.
- `CLASS`, `NEW`, `REF(...)`, and `:-` in the student and word frequency programs to define classes, create objects, declare object references, and assign references.
- `OutText`, `OutInt`, `OutFix`, and `OutImage` to print text and numeric values.

## Programs Included

### Recursive Merge Sort

Sorts a fixed array of eight integers in ascending order. The `merge_sort` procedure divides each range at its midpoint, recursively sorts the two halves, and uses `merge` to combine them. `merge` copies each half into temporary `left` and `right` arrays, compares their values, and writes them back into the original array in order. The program prints the array before and after sorting, along with comparison and remaining-value messages.

Initial values: `12, 31, 4, 3, 9, 5, 8, 24`.

### Student Grade Management System

Defines a `Student` class with an ID, name, grade array, grade count, and procedures to add grades and calculate an average. The program creates four students, adds grades to three, then prints each student's grades, average, and status. The code uses 60.0 as the pass threshold and displays a separate message for a student with no grades.

### Word Frequency Analyzer

Analyzes the fixed text `Hello, world! hello.` It scans the text, converts uppercase English letters to lowercase, groups letters and digits into words, and counts total and unique words. It prints the words alphabetically with their frequencies, a count summary, and up to three most frequent words. The frequency sort uses alphabetical order to break ties.

## Input Data

The examples use data defined in the source rather than requesting interactive input:

- **Merge sort:** `12, 31, 4, 3, 9, 5, 8, 24`
- **Student system:** S1 Ari (80.0, 90.0); S2 Bea (55.0, 65.0); S3 Cal (45.0, 50.0); S4 Dee (no grades)
- **Word analyzer:** `Hello, world! hello.`

## Program Output

The programs are written to print merge sort progress and the sorted array, a student grade report, and a word frequency report with summary counts. The supplied source document also contains example output sections; the descriptions here do not claim the programs were run for this README.

## How to Run

To run one of the programs using the Simula (cim) online compiler:

**[Open the Simula (cim) online compiler](https://tio.run/#simula)**

1. Copy the complete source code for the program you want to run.
2. Paste it into the compiler's **Code** section.
3. Click the **Run** button at the top of the page.
4. Read the program's results in the **Output** section. If an error occurs, check the **Debug** section for the compiler's error message.

Run each program separately by pasting its source code into the Code section before clicking Run. The supplied source document identifies the online compiler as GNU Cim 3.37 through Try It Online.

