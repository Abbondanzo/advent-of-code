import Utils.readFileAsList

private fun getNextDigit(history: List<Long>): Long {
    val derivatives = mutableListOf(history.toMutableList())
    while (derivatives.last().any { it != 0L }) {
        val currentDerivative = derivatives.last()
        val nextDerivative = currentDerivative.indices.toList().dropLast(1).map { index ->
            currentDerivative[index + 1] - currentDerivative[index]
        }
        derivatives.add(nextDerivative.toMutableList())
    }
    derivatives.reverse()
    for (index in derivatives.indices) {
        if (index == 0) {
            derivatives[index].add(0)
        } else {
            derivatives[index].add(derivatives[index - 1].last() + derivatives[index].last())
        }
    }
    return derivatives.last().last()
}

private fun partOne(histories: List<List<Long>>): Long {
    val lastDigits = histories.map { history -> getNextDigit(history) }
    return lastDigits.reduce { acc, i -> acc + i }
}

private fun getFirstDigit(history: List<Long>): Long {
    val derivatives = mutableListOf(history.toMutableList())
    while (derivatives.last().any { it != 0L }) {
        val currentDerivative = derivatives.last()
        val nextDerivative = currentDerivative.indices.toList().dropLast(1).map { index ->
            currentDerivative[index + 1] - currentDerivative[index]
        }
        derivatives.add(nextDerivative.toMutableList())
    }
    derivatives.reverse()
    for (index in derivatives.indices) {
        if (index == 0) {
            derivatives[index].add(0, 0)
        } else {
            derivatives[index].add(0, derivatives[index].first() - derivatives[index - 1].first())
        }
    }
    return derivatives.last().first()
}

private fun partTwo(histories: List<List<Long>>): Long {
    val firstDigits = histories.map { history -> getFirstDigit(history) }
    return firstDigits.reduce { acc, i -> acc + i }
}

fun main() {
    val input = readFileAsList("09/input").map(String::trim).filter(String::isNotEmpty)
    val histories = input.map { line -> line.split(" ").map(String::toLong) }
    println("Part 1: ${partOne(histories)}")
    println("Part 2: ${partTwo(histories)}")
}
