import strutils

type
  Student = object
    name: string
    grade: float

var
  students: seq[Student] = @[]

const maxStudents = 5

echo "=== STUDENT GRADE MANAGEMENT ==="
echo "Enter number of students (maximum ", maxStudents, "):"
let enteredCount = parseInt(readLine(stdin))

let count =
  if enteredCount < 0:
    0
  elif enteredCount > maxStudents:
    echo "Maximum limit reached. Only the first ", maxStudents, " students will be entered."
    maxStudents
  else:
    enteredCount

var total = 0.0

for i in 0..<count:
  var student: Student
  echo "\nStudent ", i + 1
  echo "Enter student name:"
  student.name = readLine(stdin)
  echo "Enter grade:"
  student.grade = parseFloat(readLine(stdin))
  students.add(student)
  total += student.grade

let average =
  if count > 0:
    total / float(count)
  else:
    0.0

echo "\n=== STUDENT RESULTS ==="
for student in students:
  echo "Name: ", student.name
  echo "Grade: ", student.grade
  if student.grade >= 75:
    echo "Status: PASSED"
  else:
    echo "Status: FAILED"
  echo "--------------------"
echo "Class Average: ", average
