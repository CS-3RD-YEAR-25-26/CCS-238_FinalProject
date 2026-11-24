fun main() {
    val numberOfGrades = 0
    val totalGrade = 0.0

    // if throw runs inside try, control passes to a catch with a matching exception type.
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
        // the typed catch parameter exposes the exception's message property.
        println(error.message)
    }
}