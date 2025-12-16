import Utils.readFileAsList


private enum class Direction {
    LEFT,
    RIGHT
}

private data class Instruction(
    val direction: Direction,
    val distance: Int,
)


private const val MAX_VALUE: Int = 100

private fun partOne(instructions: List<Instruction>): Int {
    var start = 50
    var countZeros = 0
    for (instruction in instructions) {
        val mod = if (instruction.direction == Direction.LEFT) -1 else 1
        val diff = instruction.distance * mod
        start = (start + diff + MAX_VALUE) % MAX_VALUE
        if (start == 0) {
            countZeros++
        }
    }
    return countZeros
}

private fun partTwo(instructions: List<Instruction>): Int {
    var start = 50
    var count = 0
    for (instruction in instructions) {
        var toApply = instruction.distance
        while (toApply != 0) {
           if (instruction.direction == Direction.LEFT) {
               start--
           } else {
               start++
           }
            start = (start + MAX_VALUE) % MAX_VALUE
            if (start == 0) {
                count++
            }
            toApply--
        }
    }
    return count
}


fun main() {
    val input = readFileAsList("01/input").filter { it.isNotEmpty() }
    val instructions = input.map { row ->
        val direction = when (row.first()) {
            'L' -> Direction.LEFT
            'R' -> Direction.RIGHT
            else -> error("Invalid direction ${row.first()}")
        }
        val distance = row.removeRange(0, 1).toInt()
        Instruction(direction, distance)
    }
    println("Part 1: ${partOne(instructions)}")
    println("Part 2: ${partTwo(instructions)}")
}
