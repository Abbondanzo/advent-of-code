import Utils.readFileAsList

private data class Race(
    val duration: Long,
    val distance: Long,
)

private fun getWins(race: Race): Long {
    var wins = 0L
    var potentialDuration = race.duration / 2L
    while (true) {
        if (potentialDuration == 0L) {
            break
        }
        val distance = (race.duration - potentialDuration) * potentialDuration
        if (distance > race.distance) {
            wins++
            potentialDuration--
        } else {
            break
        }
    }
    potentialDuration = race.duration / 2
    potentialDuration++
    while (true) {
        if (potentialDuration == race.duration) {
            break
        }
        val distance = (race.duration - potentialDuration) * potentialDuration
        if (distance > race.distance) {
            wins++
            potentialDuration++
        } else {
            break
        }
    }
    return wins
}

private fun partOne(input: List<String>): Long {
    val digitRegex = Regex("\\d+")
    val times = digitRegex.findAll(input[0]).map { it.value.toLong() }
    val distances = digitRegex.findAll(input[1]).map { it.value.toLong() }
    assert(times.count() == distances.count())
    val races = times.withIndex().map { (index, time) ->
        Race(time, distances.elementAt(index))
    }.toList()

    var product = 1L
    for (race in races) {
        product *= getWins(race)
    }
    return product
}

private fun partTwo(input: List<String>): Long {
    val duration = input[0].split(":")[1].replace(" ", "").toLong()
    val distance = input[1].split(":")[1].replace(" ", "").toLong()
    return getWins(Race(duration, distance))
}

fun main() {
    val input = readFileAsList("06/input").map(String::trim).filter(String::isNotEmpty)
    assert(input.size == 2)
    println("Part 1: ${partOne(input)}")
    println("Part 2: ${partTwo(input)}")
}
