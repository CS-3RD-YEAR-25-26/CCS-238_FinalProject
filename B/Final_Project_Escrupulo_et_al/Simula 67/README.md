# Simula 67 Programming Examples

These three console programs demonstrate two ways to organize a Simula 67 program. The merge sort uses recursive procedures. The grade manager and word analyzer also use classes and object references to keep related data together.

## Programs

| Program | Purpose | Main concepts |
| --- | --- | --- |
| [Recursive Merge Sort](recursive_merge_sort.sim) | Sort eight integers and show how two sorted halves are merged. | Recursion, integer division, temporary arrays |
| [Student Grade Management System](student_grade_management.sim) | Store grades and print an average and status for each student. | Classes, object references, grade validation |
| [Word Frequency Analyzer](word_frequency_analyzer.sim) | Count words and report them alphabetically and by frequency. | Text scanning, arrays of objects, sorting |

## Requirements

The project's online environment is **GNU Cim 3.37** on [Try It Online](https://tio.run/#simula). Each `.sim` file is a complete program with sample data defined in its source. You can run all three without entering anything in the **Input** panel.

## Running the programs

### Online compiler

1. Open [Try It Online with Simula selected](https://tio.run/#simula).
2. Copy one complete `.sim` file into the **Code** panel.
3. Click **Run** and read the **Output** panel. Compiler messages appear under **Debug**.
4. To try another case, change the sample values in the code and run it again.

### Local compiler

With GNU Cim installed and `cim` on your command path, open a terminal in the `Simula 67` folder. For example, on a Unix-like system, compile and run the merge sort with:

```sh
cim recursive_merge_sort.sim
./recursive_merge_sort
```

Use the corresponding filename and executable name for the other two programs.

## 1. Recursive Merge Sort

### Behavior

1. Start with the full array, positions 1 through 8.
2. For a range with at least two elements, calculate its midpoint with `(p + r) // 2` and recursively sort each half.
3. Copy the sorted halves into temporary arrays. Compare their first available values and write the smaller value back into the original array. On a tie, take the value from the left half.
4. When one half is exhausted, copy the remaining values from the other half.

### Sample input

```simula
nums(1) := 12; nums(2) := 31; nums(3) := 4; nums(4) := 3;
nums(5) := 9;  nums(6) := 5;  nums(7) := 8; nums(8) := 24;
merge_sort(nums, 1, 8);
```

### Sample output

The trace uses `OutInt(value, 1)`, so two-digit values appear as `*` in comparison and copy messages. The first and last lines use `OutInt(nums(i), 4)`, which gives each integer enough space to display in full.

```text
Array before sorting:  12  31   4   3   9   5   8  24
Comparing * and *
Adding remaining element from right half: *
Comparing 4 and 3
Adding remaining element from left half: 4
Comparing * and 3
Comparing * and 4
Adding remaining element from left half: *
Adding remaining element from left half: *
Comparing 9 and 5
Adding remaining element from left half: 9
Comparing 8 and *
Adding remaining element from right half: *
Comparing 5 and 8
Comparing 9 and 8
Comparing 9 and *
Adding remaining element from right half: *
Comparing 3 and 5
Comparing 4 and 5
Comparing * and 5
Comparing * and 8
Comparing * and 9
Comparing * and *
Comparing * and *
Adding remaining element from left half: *
Sorted array is:   3   4   5   8   9  12  24  31
```

### Main procedures

| Procedure | Responsibility |
| --- | --- |
| `merge_sort(A, p, r)` | Sort positions `p` through `r`. A range with one element needs no further work. |
| `merge(A, p, q, r)` | Merge the sorted ranges `p…q` and `q+1…r` back into `A`. |

## 2. Student Grade Management System

### Behavior

Each `Student` object stores an ID, a name, a grade array, and a count of recorded grades. The main program creates four students and uses each student's average to produce the report.

| Condition | Displayed average | Status |
| --- | --- | --- |
| Average is at least 60.0 | Average to one decimal place | `Pass` |
| Average is below 60.0 and at least one grade exists | Average to one decimal place | `Fail` |
| No grades recorded | `N/A` | `No grades` |

### Validation

`add_grade` accepts values from **0 through 100**, inclusive. An out-of-range value leaves the grade count unchanged. A recorded grade of zero counts toward the average. An empty grade list yields `-1.0`, which the report recognizes as a missing average.

### Sample records

| ID | Name | Grades |
| --- | --- | --- |
| S1 | Ari | 80, 90 |
| S2 | Bea | 55, 65 |
| S3 | Cal | 45, 50 |
| S4 | Dee | None |

### Sample output

```text
Student grade report:
S1 | Ari | Grades: 80, 90 | Average: 85.0 | Status: Pass
S2 | Bea | Grades: 55, 65 | Average: 60.0 | Status: Pass
S3 | Cal | Grades: 45, 50 | Average: 47.5 | Status: Fail
S4 | Dee | Grades: None | Average: N/A | Status: No grades
```

### Class and procedures

| Class or procedure | Responsibility |
| --- | --- |
| `Student(sid, sname)` | Store the student's ID and name, allocate the grade array, and initialize the grade count to zero. |
| `add_grade(g)` | Check the grade range and append an accepted value. |
| `calculate_average` | Sum the recorded grades and divide by their count, or return `-1.0` when the count is zero. |

## 3. Word Frequency Analyzer

### Behavior

1. Read one character at a time and convert uppercase English letters to lowercase.
2. Group consecutive letters and digits into a word. A separator or the end of the text completes the word.
3. Search the existing `WordItem` objects. Increment the count for a matching word or create an entry with a count of one.
4. Sort the entries alphabetically and print their counts.
5. Sort the same entries by descending frequency, using alphabetical order for ties. Print the total word count, unique word count, and up to three ranked entries.

### Sample input

```simula
input_text :- "Hello, world! hello.";
```

### Sample output

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

### Word entries and counts

| Name | Responsibility |
| --- | --- |
| `WordItem(wtext)` | Hold one word and its occurrence count. |
| `items` | Store references to the word entries for lookup and sorting. |
| `total_words` | Count every occurrence, including repetitions. |
| `unique_count` | Count distinct words after conversion to lowercase. |

## OOP concepts demonstrated

| Concept | Evidence in the programs |
| --- | --- |
| Classes and objects | `Student` defines the structure shared by all four students. `NEW Student("S1", "Ari")` creates one instance. |
| Instance state | Each student has a separate `grades` array and `grade_count`. Each `WordItem` tracks the count of one word. |
| Grouping data and behavior | `Student` defines `add_grade` and `calculate_average` alongside the grades they operate on. The report also reads attributes directly, such as `st.sid`. |
| Object references | `st :- students(idx)` makes `st` refer to the student being reported. The analyzer changes display order by swapping references to existing word entries. |

## Other Simula 67 features

| Feature | Example from the programs | Purpose |
| --- | --- | --- |
| Block structure | `BEGIN ... END` | Group declarations and statements. |
| Array bounds | `INTEGER ARRAY nums(1:8)` | Declare eight integer positions numbered 1 through 8. |
| Value assignment | `grade_count := 0` | Store a numeric value. |
| Integer division | `(p + r) // 2` | Calculate an integer midpoint. |
| Counted and conditional loops | `FOR ... STEP ... UNTIL ... DO`, `WHILE input_text.More DO` | Traverse known index ranges or continue while text remains. |
| Selection | `IF ... THEN ... ELSE` | Choose a merge value or determine a report status. |
| Formatted output | `OutText`, `OutInt`, `OutFix`, `OutImage` | Write text, format numbers, and finish an output line. |

## Implementation notes

- When changing the merge sort's input size, update the array bounds, the final index passed to `merge_sort`, and both output loops.
- The grade manager has room for 10 student references and 20 grades per student. The grade-range check does not check for a full array.
- The word analyzer allocates 50 characters per word and room for 100 unique entries. Keep new sample inputs within those bounds. Its word characters are English letters and digits, so punctuation and underscores separate words.
- The three sample outputs reproduce the results recorded in the project document.