fun main() {
    // Kotlin infers String and Int from the initializers. var allows pokeballs to be reassigned.
    val pokemonName = "Mewtwo"
    var pokeballs = 0

    // String templates interpolate local values with $name.
    println("===== POKEMON ENCOUNTER =====")
    println("A wild $pokemonName appeared!")
    println("Available Pokeballs: $pokeballs")

    // a try block transfers control to a matching typed catch when an exception is thrown.
    try {
        // throw raises an exception object and exits the try block immediately.
        if (pokeballs < 0) {
            throw IllegalArgumentException(
                "Invalid Pokeball quantity."
            )
        }

        // the IllegalStateException type selects the handler for an empty inventory.
        if (pokeballs == 0) {
            throw IllegalStateException(
                "No Pokeballs available."
            )
        }

        // the -= operator updates the mutable Int local.
        pokeballs -= 1

        println("Pokeball thrown successfully!")
        println("Remaining Pokeballs: $pokeballs")

    } catch (e: IllegalArgumentException) {
        // the typed catch binds the exception to e. the braces in the string template evaluate e.message.
        println("Error: ${e.message}")

    } catch (e: IllegalStateException) {
        // this separate catch binds an IllegalStateException to its own local e.
        println("Error: ${e.message}")
        println("Unable to catch Pokemon.")
    }
}