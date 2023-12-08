import Utils.readFileAsList
import Utils.repeat

typealias Instructions = List<Char>
typealias Mapping = Map<String, Pair<String, String>>

private fun getOffset(
    startingPointer: String,
    instructions: Instructions,
    map: Mapping,
    predicate: (pointer: String) -> Boolean
): Long {
    var steps = 0L
    val iterator = instructions.asSequence().repeat().iterator()
    var currentPointer = startingPointer
    while (true) {
        val nextPointer = when (val instruction = iterator.next()) {
            'L' -> map[currentPointer]!!.first
            'R' -> map[currentPointer]!!.second
            else -> error("Illegal instruction $instruction")
        }
        steps++
        if (predicate(nextPointer)) {
            break
        }
        currentPointer = nextPointer
    }
    return steps
}

private fun partOne(instructions: Instructions, map: Mapping): Long {
    return getOffset("AAA", instructions, map) { pointer -> pointer == "ZZZ" }
}

private fun lcm(a: Long, b: Long): Long {
    val larger = if (a > b) a else b
    val max = a * b
    var lcm = larger
    while (lcm <= max) {
        if (lcm % a == 0L && lcm % b == 0L) {
            return lcm
        }
        lcm += larger
    }
    return max
}

private fun partTwo(instructions: Instructions, map: Mapping): Long {
    val pointers = map.keys.filter { it.endsWith("A") }.toMutableList()
    val offsets = pointers.map { startingPointer ->
        getOffset(startingPointer, instructions, map) { pointer -> pointer.endsWith("Z") }
    }
    return offsets.reduce { acc, i -> lcm(acc, i) }
}

private fun instructionMap(input: List<String>): Mapping {
    val wordRegex = Regex("\\w+")
    val map = mutableMapOf<String, Pair<String, String>>()
    for (line in input) {
        val words = wordRegex.findAll(line).map { it.value }.toList()
        assert(words.size == 3)
        map[words[0]] = Pair(words[1], words[2])
    }
    return map
}

fun main() {
    val input = readFileAsList("08/input").map(String::trim).filter(String::isNotEmpty)

    val instructions = input[0].trim().toList()
    val steps = instructionMap(input.drop(1))

    println("Part 1: ${partOne(instructions, steps)}")
    println("Part 2: ${partTwo(instructions, steps)}")
}
