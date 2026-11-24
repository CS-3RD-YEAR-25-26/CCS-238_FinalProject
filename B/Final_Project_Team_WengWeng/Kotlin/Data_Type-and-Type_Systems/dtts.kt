fun main() {
    // declaring of variables with different data types
    val pokemonName: String = "Rayquaza"
    val pokemonType: String = "Dragon/Flying"
    val level: Int = 70
    val health: Int = 250
    val weight: Double = 206.0
    val isLegendary: Boolean = true

    // display Pokemon information
    println("===== POKEDEX =====")
    println("Pokemon: $pokemonName")
    println("Type: $pokemonType")
    println("Level: $level")
    println("Health: $health")
    println("Weight: %.2f kg".format(weight))

    // checking of legendary status
    print("Legendary: ")

    if (isLegendary) {
        println("Yes")
    } else {
        println("No")
    }
}