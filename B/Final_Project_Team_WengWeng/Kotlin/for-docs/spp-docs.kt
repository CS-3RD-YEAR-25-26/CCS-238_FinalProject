// fun declares a top-level function with typed parameters and a Double return type.
fun calculateAverage(
    programming: Double,
    math: Double,
    english: Double
): Double {
    // the Double arguments are passed by value, and return supplies the value of the call.
    return (programming + math + english) / 3
}

fun main() {
    // arguments match parameters by position, and val infers its type from the function result.
    val averageGrade = calculateAverage(
        90.0, 85.0, 88.0
    )

    println("Average Grade: $averageGrade")
}