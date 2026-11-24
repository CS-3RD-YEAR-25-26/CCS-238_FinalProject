// each var parameter in the primary constructor also declares a mutable property.
class Student(
    var studentName: String,
    var age: Int
) {
    // a member function can read the current instance's properties by name.
    fun displayInfo() {
        println("Student Name: $studentName")
        println("Age: $age")
    }
}

fun main() {
    // Kotlin infers Student from the constructor call. dot syntax invokes the instance's member function.
    val student = Student("Axel", 20)
    student.displayInfo()
}