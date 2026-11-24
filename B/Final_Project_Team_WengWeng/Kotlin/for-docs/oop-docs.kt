class Student(
    var studentName: String,
    var age: Int
) {
    fun displayInfo() {
        println("Student Name: $studentName")
        println("Age: $age")
    }
}

fun main() {
    val student = Student("Axel", 20)
    student.displayInfo()
}