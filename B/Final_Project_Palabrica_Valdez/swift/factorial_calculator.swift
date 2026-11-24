// Recursive factorial calculation with a base case for 0 and 1.
func factorial(_ number: Int) -> Int {
    if number <= 1 { return 1 }
    return number * factorial(number - 1)
}

print("Enter a whole number (0-12):")
if let text = readLine(), let n = Int(text),
   (0...12).contains(n) {
    print("Result: \(factorial(n))")
} else {
    print("Enter a whole number from 0 to 12.")
}
