import Utils.readFileAsList

private object Day25 {

  private fun parseRawInput(rawInput: List<String>): Map<String, Set<String>> {
    return rawInput.map { line ->
      line.substringBefore(":") to line
        .substringAfter(":")
        .split(" ")
        .map(String::trim)
        .filter(String::isNotEmpty)
        .toSet()
    }.associate { it }
  }

  fun parseInput(rawInput: List<String>): Set<Set<String>> {
    val mapping = parseRawInput(rawInput)
    return mapping.flatMap { entry ->
      entry.value.map { setOf(entry.key, it) }
    }.toSet()
  }

  private fun getGroupSizes(connections: Set<Set<String>>): List<Int> {
    val groups = mutableListOf<MutableSet<String>>()
    for (connection in connections) {
      val matchingGroups = groups.filter { group -> connection.any { group.contains(it) } }
      if (matchingGroups.isEmpty()) {
        groups.add(connection.toMutableSet())
      } else if (matchingGroups.size == 1) {
        groups[0].addAll(connection)
      } else {
        groups.removeAll(matchingGroups)
        println(connection)
        val flatGroup = matchingGroups.flatten().toMutableSet()
        flatGroup.addAll(connection)
        groups.add(flatGroup)
      }
    }
    return groups.map { it.size }
  }

  private fun partOneHelper(connections: Set<Set<String>>, toRemove: Int): List<List<Int>> {
    if (toRemove == 0) {
      return listOf(getGroupSizes(connections))
    }
    return connections.flatMap { connection ->
      if (toRemove == 1) {
        println(connections.indexOf(connection))
      }
      partOneHelper(connections.minusElement(connection), toRemove - 1)
    }
  }

  fun partOne(connections: Set<Set<String>>) {
    val results = partOneHelper(connections, 3)
    println(results.filter { it.size > 1 })
  }

  fun partTwo(input: List<String>) {
    // TODO("Not yet implemented")
  }
}

fun main() {
  val input = readFileAsList("25/input").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${Day25.partOne(Day25.parseInput(input))}")
  println("Part 2: ${Day25.partTwo(input)}")
}
