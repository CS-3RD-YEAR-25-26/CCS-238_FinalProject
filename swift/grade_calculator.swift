print("Student name:")
let student = readLine() ?? ""
print("Grade:")
if let text = readLine(), let grade = Int(text),
   (0...100).contains(grade) {
    print("Student: \(student)")
    print("Grade: \(grade)")
    print(grade >= 75 ? "Status: Passed"
                      : "Status: Failed")
} else {
    print("Status: Invalid grade")
}
