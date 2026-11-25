print("Student name:")
let student = readLine() ?? ""
print("Grade:")
// Int input keeps the grade as a whole number, then the range check
// rejects values outside the valid 0...100 scale.
if let text = readLine(), let grade = Int(text),
   (0...100).contains(grade) {
    print("Student: \(student)")
    print("Grade: \(grade)")
    print(grade >= 75 ? "Status: Passed"
                      : "Status: Failed")
} else {
    print("Status: Invalid grade")
}
