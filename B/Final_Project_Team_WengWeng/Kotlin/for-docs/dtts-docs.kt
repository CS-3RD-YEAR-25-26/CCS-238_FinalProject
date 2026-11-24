fun main() {
    var studentName: String = "Joelmar"
    var studentID: String = "2023M2082"

    var age: Int = 20 // or var age = 20 to show Kotlin infers Int

    var programmingGrade: Double = 90.0
    var mathematicsGrade: Double = 85.0
    var englishGrade: Double = 88.0

    var averageGrade: Double =
        (programmingGrade +
         mathematicsGrade +
         englishGrade) / 3

    // --- Output Section ---
    println("Student Name: $studentName")
    println("Student ID:   $studentID")
    println("Age:          $age")
    println("Programming:  $programmingGrade")
    println("Mathematics:  $mathematicsGrade")
    println("English:      $englishGrade")
    println("Average:      ${"%.2f".format(averageGrade)}")
}
