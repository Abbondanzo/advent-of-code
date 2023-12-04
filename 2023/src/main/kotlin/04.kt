import Utils.readFileAsList
import kotlin.math.pow

private val DIGIT_REGEX = Regex("\\d+")

private fun getWins(row: String): Int {
    val split = row.split(":")[1].split("|")
    assert(split.size == 2)
    val winningNumbers = DIGIT_REGEX.findAll(split[0]).map { matchResult -> matchResult.value.toInt() }.toSet()
    val yourNumbers = DIGIT_REGEX.findAll(split[1]).map { matchResult -> matchResult.value.toInt() }.toList()
    return yourNumbers.count { number -> winningNumbers.contains(number) }
}

private fun partOne(input: List<String>): Int {
    var total = 0
    input.map { card ->
        val matches = getWins(card)
        total += 2.0.pow(matches - 1).toInt()
    }
    return total
}

private fun partTwo(input: List<String>): Int {
    val winMap = input.map { card -> getWins(card) }.toMutableList()
    val cards = winMap.map { 1 }.toMutableList()
    cards[0] = 1
    for (index in winMap.indices) {
        val winCount = winMap[index]
        for (i in (index + 1)..index + winCount) {
            cards[i] = cards[i] + cards[index]
        }
    }
    return cards.reduce { acc, i -> acc + i }
}

fun main() {
    val input = readFileAsList("04/input").filter(String::isNotEmpty).map(String::trim)
    println("Part 1: ${partOne(input)}")
    println("Part 2: ${partTwo(input)}")
}
