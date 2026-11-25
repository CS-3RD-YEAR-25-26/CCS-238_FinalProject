# GNU Smalltalk Programming Examples

Three console programs were implemented using **GNU Smalltalk** : Recursive Merge Sort, Student Grade Management System, and Word Frequency Analyzer. The examples demonstrate recursion, classes and objects, message passing, blocks, collection processing, and input validation.

## Programs

| Program | Purpose | Main concepts |
| --- | --- | --- |
| Recursive Merge Sort | Sort an array in ascending order and print the merge operations. | Recursion, arrays, comparison, and loops |
| Student Grade Management System | Store student records, validate grades, calculate averages, and generate reports. | Classes, objects, instance state, abstraction, and dictionaries |
| Word Frequency Analyzer | Count words and report alphabetical frequencies and the most frequent words. | Strings, regular expressions, dictionaries, associations, and blocks |

## Requirements

- A compatible **GNU Smalltalk** interpreter or online compiler. The programs were executed using the online compiler JDoodle (https://www.jdoodle.com/execute-smalltalk-online) version 3.2.92.
- GNU Smalltalk's regular-expression support for `allOccurrencesOfRegex:` in the word analyzer.
- A console or output panel to display `Transcript` messages.

The programs use GNU-specific file syntax, including bracketed class definitions and `Eval [ ... ]`. They may require changes before use in another Smalltalk environment such as Pharo or Squeak.


## Running the programs

### Online compiler

1. Open the online compiler and it should automatically load Smalltalk as the language.
2. Paste one complete program, including its class definitions and final `Eval` block.
3. Run the program and inspect the output panel.
4. Change the sample input inside `Eval` to try another case.

The examples use hard-coded inputs; they do not prompt for keyboard input.

### Local interpreter

With the `gst` executable installed and available on your command path, run each program separately:

```sh
gst recursive_merge.sort.gst
gst student_grade_management.gst
gst word_frequency_analyzer.gst
```


## 1. Recursive Merge Sort

### Behavior

The `MergeSort` object receives an array through `sort:`. It recursively sorts smaller portions and merges them into a new array.

1. Return immediately when the array contains zero or one element.
2. Split the array into left and right portions.
3. Recursively sort both portions.
4. Compare their current elements and copy the smaller one into the result.
5. Copy any remaining elements and return the result.

The program prints comparisons and leftover-copy operations to make the merge process visible.

### Sample input

```smalltalk
inputArr := #(12 31 4 3 9 5 8 24).
outputArr := MergeSort new sort: inputArr.
```

### Sample result

```text
Array before sorting: (12 31 4 3 9 5 8 24 )
```

Comparison and remaining-element messages appear between the input and final result:

```text
Sorted array is: (3 4 5 8 9 12 24 31 )
```

Array-printing whitespace can vary by runtime.

### Main method

| Method | Responsibility |
| --- | --- |
| `MergeSort >> sort:` | Return an array containing the input elements in ascending order. |

Smalltalk arrays use **1-based indexing**. The method constructs result arrays rather than sorting the supplied array in place. Input elements must support compatible `<=` comparisons.

## 2. Student Grade Management System

### Behavior

The program stores students by ID and records each student's grades. It calculates an average and reports one of three statuses:

| Condition | Status |
| --- | --- |
| Average is at least 60 | `Pass` |
| Average is below 60 | `Fail` |
| No grades are recorded | `No grades` |

When no grades exist, `calcAverage` returns `nil`. The report displays `N/A` for the average and `None` for the grade list.

### Validation

- IDs and names must not be blank after surrounding separator whitespace is removed for the check.
- Student IDs must be unique.
- Recording or displaying a student requires an existing ID.
- Grades must belong to the `Integer` or `Float` class families.
- Floating-point grades must be finite.
- Grades must be within **0–100**, inclusive.

Invalid operations signal an error through `self error:`. The supplied example does not add a custom error-recovery interface.

### Sample records

| ID | Name | Grades |
| --- | --- | --- |
| S1 | Ari | 80, 90 |
| S2 | Bea | 55, 65 |
| S3 | Cal | 45, 50 |
| S4 | Dee | No grades |

### Sample output

```text
Student grade report:
S1 | Ari | Grades: 80, 90 | Average: 85.0 | Status: Pass
S2 | Bea | Grades: 55, 65 | Average: 60.0 | Status: Pass
S3 | Cal | Grades: 45, 50 | Average: 47.5 | Status: Fail
S4 | Dee | Grades: None | Average: N/A | Status: No grades
```

### Classes and methods

| Class | Method | Responsibility |
| --- | --- | --- |
| `Student` | Class-side `id:name:` | Create and initialize a student. |
| `Student` | `initializeId:name:` | Store the ID and name and create an empty grades collection. |
| `Student` | `studentID`, `name`, `grades` | Return the stored information. |
| `Student` | `addGrade:` | Validate and store a grade. |
| `Student` | `calcAverage` | Return the average as a float, or `nil` when grades are absent. |
| `Student` | `getStatus` | Return the pass/fail/no-grades status. |
| `StudentGradeManagementSystem` | `addStudent:name:` | Validate student details and store the student by ID. |
| `StudentGradeManagementSystem` | `recordGrade:grade:` | Find a student and delegate grade validation and storage. |
| `StudentGradeManagementSystem` | `displayStudent:` | Return one formatted report string. |
| `StudentGradeManagementSystem` | `displayAllStudents` | Return report strings in sorted student-ID order. |

Despite their names, the `display...` methods return strings or collections of strings. The final `Eval` block prints them.

## 3. Word Frequency Analyzer

### Behavior

The `WordAnalyzer` receives text through `analyzeText:` and:

1. Converts the input to lowercase.
2. Extracts words using `'[^\W_]+'`.
3. Counts occurrences in a dictionary.
4. Sorts word-count associations alphabetically.
5. Ranks associations by descending frequency, with alphabetical order for ties.
6. Returns the alphabetical entries, total word count, and ranked entries.

The `Eval` block displays the results and selects up to three of the most frequent words.

### Sample input

```smalltalk
inputText := 'Hello, world! hello.'.
```

### Sample output

```text
Paragraph: Hello, world! hello.
Word Frequencies (alphabetical):
hello: 2
world: 1
Text summary:
Total words: 3
Unique words: 2
Most frequent words: hello (2)
world (1)
```

Repeated occurrences contribute to the total count, so this sample has **3 total words** and **2 unique words**. Punctuation and underscores separate words according to the regex's character rules.

### Return value

`analyzeText:` returns a three-element array:

| Position | Value |
| --- | --- |
| 1 | Array of word-count associations in alphabetical order |
| 2 | Total number of word occurrences |
| 3 | Array of word-count associations ranked by frequency |

Each association exposes its word through `key` and its count through `value`. The alphabetical result is an **array of associations**, not a dictionary.

## OOP concepts demonstrated

| Concept | Evidence in the programs |
| --- | --- |
| Classes and objects | `Student`, `MergeSort`, and `WordAnalyzer` define classes; class-side creation messages produce instances. |
| Encapsulation | Student data and grade-processing methods are grouped in one object; outside code uses messages to access its state. |
| Abstraction | Callers request operations such as `calcAverage` without repeating their internal steps. |
| Message passing | Expressions such as `student addGrade: 90` and `self calcAverage` request behavior from a receiver. |
| Basic inheritance | Classes are explicitly defined as subclasses of `Object`. |
| Method overriding and `super` | The management system and analyzer define class-side `new` methods and delegate inherited creation through `super new`. |

The examples do not define a custom hierarchy of student subclasses with different implementations of the same operation. Creating several `Student` instances alone does not demonstrate that form of polymorphism.

## Other Smalltalk features

| Feature | Example | Purpose |
| --- | --- | --- |
| Assignment | `sum := 0` | Bind a variable to a value. |
| Return | `^result` | Return from the current method invocation. |
| Block argument | `[:grade \| ...]` | Receive an item when a block executes. |
| Iteration | `grades do: [...]` | Execute a block for every item. |
| Conditional evaluation | `condition ifTrue: [...]` | Execute a block when the receiver is true. |
| Short-circuit logic | `condition and: [...]` | Evaluate the second condition only when needed. |
| Dictionary fallback | `counts at: word ifAbsent: [0]` | Supply zero when a word has no stored count. |
| Cascade | `Transcript show: 'Hello'; cr` | Send multiple messages to the same receiver. |
| Dynamic array construction | `{first. second. third}` | Build an array from evaluated expressions. |

## Implementation notes

- These are console demonstrations with in-memory data; they do not include a GUI, database, or file persistence.
- The `Student` getters expose the actual grades collection. Callers can modify it directly, so validation is guaranteed only for additions made through `addGrade:`.
- Blank student fields are checked using trimmed text, but the original ID and name strings are stored.
- The grade thresholds are class variables in this GNU Smalltalk syntax, not enforced constants.
- GNU Smalltalk's documented regex engine does not provide full Unicode support. The word-extraction pattern should not be described as fully equivalent to Python's Unicode-aware matching.
- The analyzer's initialized instance variables are separate from similarly named variables in `Eval`; the analysis method returns its results rather than updating those instance variables.
- If copying code from a PDF, remove invisible formatting characters and restore any statements split by page breaks.

The sample results above are taken from the supplied project document; they are not a claim of a new execution or automated test run.

