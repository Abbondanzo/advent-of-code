import Utils.readFileAsList

fun partOne(input: List<String>): Int {
    val digitRegex = Regex("\\d")
    var total = 0
    input.forEach {
        val matches = digitRegex.findAll(it)
        if (matches.firstOrNull() == null) {
            return@forEach
        }
        val first = matches.first().value.toInt()
        val last = matches.last().value.toInt()
        total += (first * 10) + last
    }
    return total
}

fun replaceWords(match: String): Int {
    return when (match) {
        "one" -> 1
        "two" -> 2
        "three" -> 3
        "four" -> 4
        "five" -> 5
        "six" -> 6
        "seven" -> 7
        "eight" -> 8
        "nine" -> 9
        else -> match.toInt()
    }
}

fun partTwo(input: List<String>): Int {
    val wordRegex = Regex("(?=(one|two|three|four|five|six|seven|eight|nine|\\d))")
    var total = 0
    input.forEach {
        val matches = wordRegex.findAll(it)
        val groups = matches
            .flatMap { match -> match.groups }
            .filterNotNull()
            .map { group -> group.value }
            .filter { value -> value.isNotEmpty() }
        val first = replaceWords(groups.first())
        val last = replaceWords(groups.last())
        total += (first * 10) + last
    }
    return total
}

fun main() {
    val input = readFileAsList("01/input").filter { it.isNotEmpty() }
    println("Part 1: ${partOne(input)}")
    println("Part 2: ${partTwo(input)}")
}
