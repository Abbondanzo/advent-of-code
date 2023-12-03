import Utils.readFileAsList

private fun isAdjacentChar(input: List<String>, row: Int, col: Int): Boolean {
    for (r in (row - 1)..(row + 1)) {
        for (c in (col - 1)..(col + 1)) {
            val char = input.getOrNull(r)?.getOrNull(c) ?: continue
            if (!char.isDigit() && char != '\r' && char != '.') {
                return true
            }
        }
    }
    return false
}

private fun partOne(input: List<String>): Int {
    var total = 0
    for (rowIndex in input.indices) {
        val row = input[rowIndex]
        var builder = StringBuilder()
        var isAdjacent = false

        for (colIndex in row.indices) {
            val char = row[colIndex]
            if (char.isDigit()) {
                builder.append(char)
                isAdjacent = isAdjacent || isAdjacentChar(input, rowIndex, colIndex)
            } else if (builder.isNotEmpty()) {
                if (isAdjacent) {
                    val value = builder.toString()
                    total += value.toInt()
                }
                builder = StringBuilder()
                isAdjacent = false
            }
        }
        if (isAdjacent && builder.isNotEmpty()) {
            total += builder.toString().toInt()
        }
    }
    return total
}

private fun getPartNumbers(input: List<String>, row: Int, col: Int): MutableList<Int> {
    val partNumbers = mutableListOf<Int>()
    for (r in (row - 1)..(row + 1)) {
        var builder = StringBuilder()
        var isAdjacent = false
        for (c in (col - 3)..(col + 3)) {
            val char = input.getOrNull(r)?.getOrNull(c) ?: continue
            if (char.isDigit()) {
                builder.append(char)
                isAdjacent = isAdjacent || (c in (col - 1)..(col+1))
            } else if (builder.isNotEmpty()) {
                if (isAdjacent) {
                    partNumbers.add(builder.toString().toInt())
                }
                builder = StringBuilder()
                isAdjacent = false
            }
        }
        if (isAdjacent && builder.isNotEmpty()) {
            partNumbers.add(builder.toString().toInt())
        }
    }
    return partNumbers
}

private fun partTwo(input: List<String>): Int {
    var total = 0
    for (rowIndex in input.indices) {
        val row = input[rowIndex]
        for (colIndex in row.indices) {
            val char = row[colIndex]
            if (char == '*') {
                val partNumbers = getPartNumbers(input, rowIndex, colIndex)
                if (partNumbers.size == 2) {
                    total += (partNumbers[0] * partNumbers[1])
                }
            }
        }
    }
    return total
}

fun main() {
    val input = readFileAsList("03/input").filter { it.isNotEmpty() }.toMutableList()
    println("Part 1: ${partOne(input)}")
    println("Part 2: ${partTwo(input)}")
}
