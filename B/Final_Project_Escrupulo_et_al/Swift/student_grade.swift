import Foundation

// Student Grade Management System

// Swift uses let for constants that cannot be reassigned.
let PASSING_GRADE = 60.0
let MIN_GRADE = 0.0
let MAX_GRADE = 100.0

// Swift enums can define custom error cases.
// These errors are used when student data is invalid.
enum StudentError: Error {
    case invalidGrade
    case invalidStudentInfo
    case duplicateStudent(String)
    case studentNotFound(String)
}

// A class is a reference type in Swift.
// Its properties store the student's information.
class Student {
    let studentID: String
    let name: String
    var grades: [Double]

    // init is Swift's initializer for creating objects.
    init(studentID: String, name: String) {
        self.studentID = studentID
        self.name = name
        self.grades = []
    }

    // throws indicates that this method may produce an error.
    func addGrade(_ grade: Double) throws {
        guard grade.isFinite &&
              grade >= MIN_GRADE &&
              grade <= MAX_GRADE else {
            throw StudentError.invalidGrade
        }

        grades.append(grade)
    }

    // Double? is an optional that can contain a number or nil.
    // nil represents the absence of a computed average.
    func calculateAverage() -> Double? {
        if grades.isEmpty {
            return nil
        }

        let total = grades.reduce(0.0, +)
        return total / Double(grades.count)
    }

    // Optional binding safely unwraps the computed average.
    func getStatus() -> String {
        guard let average = calculateAverage() else {
            return "No grades"
        }

        return average >= PASSING_GRADE ? "Pass" : "Fail"
    }
}

class StudentGradeManagementSystem {

    // Swift dictionaries store key-value pairs.
    // Student IDs are keys, and Student objects are values.
    var students: [String: Student] = [:]

    func addStudent(_ studentID: String, _ name: String) throws {
        if studentID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw StudentError.invalidStudentInfo
        }

        if students[studentID] != nil {
            throw StudentError.duplicateStudent(studentID)
        }

        students[studentID] = Student(
            studentID: studentID,
            name: name
        )
    }

    func recordGrade(_ studentID: String, _ grade: Double) throws {
        // guard let safely retrieves a value from a dictionary.
        guard let student = students[studentID] else {
            throw StudentError.studentNotFound(studentID)
        }

        try student.addGrade(grade)
    }

    func displayStudent(_ studentID: String) throws -> String {
        guard let student = students[studentID] else {
            throw StudentError.studentNotFound(studentID)
        }

        let average = student.calculateAverage()

        // Swift's optional mapping formats the average
        // only when a value exists.
        let averageText = average.map {
            String(format: "%.1f", $0)
        } ?? "N/A"

        // map transforms each grade into a string.
        // joined combines the values with commas.
        let gradesText = student.grades.isEmpty
            ? "None"
            : student.grades.map {
                String(format: "%g", $0)
              }.joined(separator: ", ")

        return "\(student.studentID) | \(student.name) | Grades: \(gradesText) | Average: \(averageText) | Status: \(student.getStatus())"
    }

    func displayAllStudents() throws -> [String] {
        var output: [String] = []

        // sorted() arranges dictionary keys alphabetically.
        for studentID in students.keys.sorted() {
            let summary = try displayStudent(studentID)
            output.append(summary)
        }

        return output
    }
}

// Swift tuples group related values.
// The records match the Python baseline.
let studentRecords: [(String, String, [Double])] = [
    ("S1", "Ari", [80, 90]),
    ("S2", "Bea", [55, 65]),
    ("S3", "Cal", [45, 50]),
    ("S4", "Dee", [])
]

var output: [String] = []
let system = StudentGradeManagementSystem()

// do-catch handles errors thrown by Swift functions.
do {
    for (studentID, name, grades) in studentRecords {
        try system.addStudent(studentID, name)

        for grade in grades {
            try system.recordGrade(studentID, grade)
        }
    }

    print("Student grade report:")
    output = try system.displayAllStudents()

    for studentSummary in output {
        print(studentSummary)
    }

} catch {
    print("Error: \(error)")
}
