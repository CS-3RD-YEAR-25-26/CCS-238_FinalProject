fun main() {
    // declaring and assigning of inventory information
    val pokemonName = "Mewtwo"
    var pokeballs = 0

    // display Pokemon encounter information
    println("===== POKEMON ENCOUNTER =====")
    println("A wild $pokemonName appeared!")
    println("Available Pokeballs: $pokeballs")

    try {
        // checking if the inventory is invalid
        if (pokeballs < 0) {
            throw IllegalArgumentException(
                "Invalid Pokeball quantity."
            )
        }

        // checking if Pokeballs are available
        if (pokeballs == 0) {
            throw IllegalStateException(
                "No Pokeballs available."
            )
        }

        // execution of a valid catching attempt
        pokeballs -= 1

        println("Pokeball thrown successfully!")
        println("Remaining Pokeballs: $pokeballs")

    } catch (e: IllegalArgumentException) {
        // handling of invalid inventory quantity
        println("Error: ${e.message}")

    } catch (e: IllegalStateException) {
        // handling of unavailable Pokeballs
        println("Error: ${e.message}")
        println("Unable to catch Pokemon.")
    }
}