fun main() {
    // val declares a read-only binding, with its explicit type after the colon.
    val pokemonName: String = "Rayquaza"
    val pokemonType: String = "Dragon/Flying"
    val level: Int = 70
    val health: Int = 250
    val weight: Double = 206.0
    val isLegendary: Boolean = true

    // String templates interpolate values with $name. String.format uses %.2f for two decimal places.
    println("===== POKEDEX =====")
    println("Pokemon: $pokemonName")
    println("Type: $pokemonType")
    println("Level: $level")
    println("Health: $health")
    println("Weight: %.2f kg".format(weight))

    // Kotlin requires a Boolean condition in if, so isLegendary can be used directly.
    print("Legendary: ")

    if (isLegendary) {
        println("Yes")
    } else {
        println("No")
    }
}