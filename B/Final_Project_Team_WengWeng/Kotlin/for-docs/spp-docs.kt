fun calculateAverage(
    programming: Double,
    math: Double,
    english: Double
): Double {
    return (programming + math + english) / 3
}

fun main() {
    val averageGrade = calculateAverage(
        90.0, 85.0, 88.0
    )

    println("Average Grade: $averageGrade")
}