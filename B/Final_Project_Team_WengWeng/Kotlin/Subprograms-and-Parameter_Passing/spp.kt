// defining of a function to calculate attack damage
fun calculateDamage(
    baseDamage: Double,
    multiplier: Double
): Double {
    // calculation and returning of final damage
    return baseDamage * multiplier
}

fun main() {
    // declaring and assigning of attack information
    val attackDamage = 60.0
    val effectiveness = 2.0

    // calling of the function with parameters
    val finalDamage = calculateDamage(
        attackDamage, effectiveness
    )

    // display attack information
    println("===== POKEMON DAMAGE CALCULATOR =====")
    println("Attacker: Pikachu")
    println("Opponent: Gyarados")
    println("Move: Thunderbolt")

    println("Base Damage: %.2f".format(attackDamage))
    println("Effectiveness: %.2fx".format(effectiveness))

    // display the returned damage value
    println("Final Damage: %.2f".format(finalDamage))
    println("It's super effective!")
}