// defining of a class with Pokemon attributes
class Pokemon(
    val pokemonName: String,
    var health: Int,
    val damage: Int
) {
    // defining of a function to receive damage
    fun receiveDamage(amount: Int) {
        health -= amount

        if (health < 0) {
            health = 0
        }
    }

    // defining of a function to display Pokemon details
    fun displayInfo() {
        println("$pokemonName - HP: $health")
    }
}

fun main() {
    // creation of two Pokemon objects
    val pikachu = Pokemon("Pikachu", 100, 30)
    val charizard = Pokemon("Charizard", 150, 50)

    // display Pokemon health before battle
    println("===== BEFORE BATTLE =====")

    pikachu.displayInfo()
    charizard.displayInfo()

    // execution of attacks between Pokemon objects
    charizard.receiveDamage(pikachu.damage)
    pikachu.receiveDamage(charizard.damage)

    // display Pokemon health after battle
    println()
    println("===== AFTER BATTLE =====")

    pikachu.displayInfo()
    charizard.displayInfo()
}