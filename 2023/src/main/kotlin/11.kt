import Utils.readFileAsList
import kotlin.math.abs

private data class Galaxy(
    val x: Long,
    val y: Long
) {
    fun distanceTo(other: Galaxy): Long {
        return abs(x - other.x) + abs(y - other.y)
    }
}

private fun getGalaxies(input: List<String>, multiplier: Long = 1): Set<Galaxy> {
    val emptyRows = input.indices.filter { rowIndex ->
        input[rowIndex].all { it == '.' }
    }
    val emptyColumns = input[0].indices.filter { columnIndex ->
        input.all { it[columnIndex] == '.' }
    }
    val galaxies = mutableSetOf<Galaxy>()
    for (rowIndex in input.indices) {
        for (columnIndex in input[0].indices) {
            val char = input[rowIndex][columnIndex]
            if (char == '#') {
                val rowExpandCount = emptyRows.count { it < rowIndex } * (multiplier - 1)
                val colExpandCount = emptyColumns.count { it < columnIndex } * (multiplier - 1)
                galaxies.add(Galaxy(columnIndex + colExpandCount, rowIndex + rowExpandCount))
            }
        }
    }
    return galaxies
}

private fun getDistances(input: List<String>, multiplier: Long): Long {
    val galaxies = getGalaxies(input, multiplier).toList()
    var distances = 0L
    for (i in galaxies.indices) {
        for (j in (i + 1)..< galaxies.size) {
            val distance = galaxies[i].distanceTo(galaxies[j])
            distances += distance
        }
    }
    return distances
}

private fun partOne(input: List<String>): Long {
    return getDistances(input, 2)
}

private fun partTwo(input: List<String>): Long {
    return getDistances(input, 1000000)
}

fun main() {
    val input = readFileAsList("11/input").map(String::trim).filter(String::isNotEmpty)
    println("Part 1: ${partOne(input)}")
    println("Part 2: ${partTwo(input)}")
}
