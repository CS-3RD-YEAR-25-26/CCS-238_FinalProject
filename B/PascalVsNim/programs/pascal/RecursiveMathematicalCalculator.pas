program RecursiveMathematicalCalculator;

function Factorial(n: integer): int64;
begin
  if n <= 1 then
    Factorial := 1
  else
    Factorial := n * Factorial(n - 1);
end;

function Fibonacci(n: integer): int64;
begin
  if n <= 1 then
    Fibonacci := n
  else
    Fibonacci := Fibonacci(n - 1) + Fibonacci(n - 2);
end;

var
  num, terms, i: integer;

begin
  writeln('=== RECURSIVE MATHEMATICAL CALCULATOR ===');
  write('Enter a number for factorial: ');
  readln(num);

  if num < 0 then
    writeln('Factorial is not defined for negative numbers.')
  else
    writeln('Factorial of ', num, ' = ', Factorial(num));

  writeln;
  write('Enter number of Fibonacci terms: ');
  readln(terms);

  if terms <= 0 then
    writeln('Please enter a positive number.')
  else
  begin
    writeln('Fibonacci Sequence:');
    for i := 0 to terms - 1 do
      writeln(Fibonacci(i));
  end;
end.
