// fun declares a top-level function with Double parameters and a Double return type.
fun calculateDamage(
    baseDamage: Double,
    multiplier: Double
): Double {
    // return supplies the Double value of the multiplication to the caller.
    return baseDamage * multiplier
}

fun main() {
    // Kotlin infers Double from the decimal literals used to initialize these val bindings.
    val attackDamage = 60.0
    val effectiveness = 2.0

    // positional arguments match parameters in declaration order and are passed by value.
    val finalDamage = calculateDamage(
        attackDamage, effectiveness
    )

    // println writes a line and returns Unit.
    println("===== POKEMON DAMAGE CALCULATOR =====")
    println("Attacker: Pikachu")
    println("Opponent: Gyarados")
    println("Move: Thunderbolt")

    println("Base Damage: %.2f".format(attackDamage))
    println("Effectiveness: %.2fx".format(effectiveness))

    // the String.format extension formats the returned Double with two decimal places.
    println("Final Damage: %.2f".format(finalDamage))
    println("It's super effective!")
}