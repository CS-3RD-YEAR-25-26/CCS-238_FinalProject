// the primary constructor declares read-only val properties and a mutable var property.
class Pokemon(
    val pokemonName: String,
    var health: Int,
    val damage: Int
) {
    // this member function updates the current instance's health with -= and implicitly returns Unit.
    fun receiveDamage(amount: Int) {
        health -= amount

        if (health < 0) {
            health = 0
        }
    }

    // String templates read the current instance's properties by name.
    fun displayInfo() {
        println("$pokemonName - HP: $health")
    }
}

fun main() {
    // calling the class by name invokes its constructor. each val binding holds an object reference.
    val pikachu = Pokemon("Pikachu", 100, 30)
    val charizard = Pokemon("Charizard", 150, 50)

    // dot syntax invokes a member function on the selected instance, with parentheses for an empty argument list.
    println("===== BEFORE BATTLE =====")

    pikachu.displayInfo()
    charizard.displayInfo()

    // dot syntax also reads a property, so one object's damage can be passed to another object's method.
    charizard.receiveDamage(pikachu.damage)
    pikachu.receiveDamage(charizard.damage)

    // a val reference keeps pointing to the same object while its var health property changes.
    println()
    println("===== AFTER BATTLE =====")

    pikachu.displayInfo()
    charizard.displayInfo()
}