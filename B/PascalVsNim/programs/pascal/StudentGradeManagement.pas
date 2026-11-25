program StudentGradeManagement;

type
  Student = record
    name: string;
    grade: real;
  end;

var
  students: array[1..100] of Student;
  count, i, enteredCount: integer;
  total, average: real;

begin
  writeln('=== STUDENT GRADE MANAGEMENT ===');
  write('Enter number of students (maximum 5): ');
  readln(enteredCount);

  if enteredCount < 0 then
    count := 0
  else if enteredCount > 5 then
  begin
    writeln('Maximum limit reached. Only the first 5 students will be entered.');
    count := 5;
  end
  else
    count := enteredCount;

  total := 0;

  for i := 1 to count do
  begin
    writeln;
    writeln('Student ', i);
    write('Enter student name: ');
    readln(students[i].name);
    write('Enter grade: ');
    readln(students[i].grade);
    total := total + students[i].grade;
  end;

  if count > 0 then
    average := total / count
  else
    average := 0;

  writeln;
  writeln('=== STUDENT RESULTS ===');
  for i := 1 to count do
  begin
    writeln('Name: ', students[i].name);
    writeln('Grade: ', students[i].grade:0:2);

    if students[i].grade >= 75 then
      writeln('Status: PASSED')
    else
      writeln('Status: FAILED');

    writeln('--------------------');
  end;
  writeln('Class Average: ', average:0:2);
end.
