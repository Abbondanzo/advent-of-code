import Utils.readFileAsList

private val RED_REGEX = Regex("(\\d+) red")
private val GREEN_REGEX = Regex("(\\d+) green")
private val BLUE_REGEX = Regex("(\\d+) blue")

private data class Round(
    val red: Int,
    val green: Int,
    val blue: Int,
)

private data class Game(
    val id: Int,
    val rounds: List<Round>,
)

private fun rowToGame(row: String): Game {
    val id = Regex("Game (\\d+):").find(row)!!.groups[1]!!.value.toInt()
    val rounds = row.split(":")[1].split(";").map { round ->
        val reds = RED_REGEX.find(round)?.groups?.get(1)?.value?.toInt() ?: 0
        val greens = GREEN_REGEX.find(round)?.groups?.get(1)?.value?.toInt() ?: 0
        val blues = BLUE_REGEX.find(round)?.groups?.get(1)?.value?.toInt() ?: 0
        Round(reds, greens, blues)
    }
    return Game(id, rounds)
}

private fun partOne(input: List<String>): Int {
    val games = input.map(::rowToGame)
    var total = 0
    games.forEach { game ->
        val inLimits = game.rounds.all { round -> round.red <= 12 && round.green <= 13 && round.blue <= 14 }
        if (inLimits) {
            total += game.id
        }
    }
    return total
}

private fun partTwo(input: List<String>): Int {
    val games = input.map(::rowToGame)
    val sums = games.map { game ->
        val minRed = game.rounds.maxOf { it.red }
        val minGreen = game.rounds.maxOf { it.green }
        val minBlue = game.rounds.maxOf { it.blue }
        minRed * minGreen * minBlue
    }
    return sums.reduce { acc, i -> acc + i }
}

fun main() {
    val input = readFileAsList("02/input").filter { it.isNotEmpty() }

    println("Part 1: ${partOne(input)}")
    println("Part 2: ${partTwo(input)}")
}
