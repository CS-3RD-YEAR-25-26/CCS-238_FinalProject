import strutils

proc factorial(n: int): int64 =
  if n <= 1:
    return 1
  else:
    return int64(n) * factorial(n - 1)

proc fibonacci(n: int): int64 =
  if n <= 1:
    return int64(n)
  else:
    return fibonacci(n - 1) + fibonacci(n - 2)

echo "=== RECURSIVE MATHEMATICAL CALCULATOR ==="

echo "\nEnter a number for factorial:"
let num = parseInt(readLine(stdin))

if num < 0:
  echo "Factorial is not defined for negative numbers."
else:
  echo "Factorial of ", num, " = ", factorial(num)

echo "\nEnter number of Fibonacci terms:"
let terms = parseInt(readLine(stdin))

if terms <= 0:
  echo "Please enter a positive number."
else:
  echo "Fibonacci Sequence:"
  for i in 0..<terms:
    echo fibonacci(i)
