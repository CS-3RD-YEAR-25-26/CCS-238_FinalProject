fun main() {
    // var declares a reassignable local, with its explicit type after the colon.
    var studentName: String = "Joelmar"
    var studentID: String = "2023M2082"

    var age: Int = 20 // Kotlin would infer Int from 20 if the annotation were omitted.

    var programmingGrade: Double = 90.0
    var mathematicsGrade: Double = 85.0
    var englishGrade: Double = 88.0

    // dividing the Double sum by an Int literal produces a Double.
    var averageGrade: Double =
        (programmingGrade +
         mathematicsGrade +
         englishGrade) / 3

    // use $name for a simple identifier and dollar-sign braces for an expression such as a format call.
    println("Student Name: $studentName")
    println("Student ID:   $studentID")
    println("Age:          $age")
    println("Programming:  $programmingGrade")
    println("Mathematics:  $mathematicsGrade")
    println("English:      $englishGrade")
    println("Average:      ${"%.2f".format(averageGrade)}")
}
