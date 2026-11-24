fun main() {
    val numberOfGrades = 0
    val totalGrade = 0.0

    try {
        if (numberOfGrades == 0) {
            throw IllegalArgumentException(
                "No grades available."
            )
        }

        val averageGrade =
            totalGrade / numberOfGrades

        println("Average Grade: $averageGrade")
    } catch (error: IllegalArgumentException) {
        println(error.message)
    }
}