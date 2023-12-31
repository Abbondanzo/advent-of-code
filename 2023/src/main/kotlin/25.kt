import Utils.readFileAsList
import kotlin.random.Random

private object Day25 {

  private fun parseRawInput(rawInput: List<String>): Map<String, Set<String>> {
    return rawInput
        .map { line ->
          line.substringBefore(":") to
              line
                  .substringAfter(":")
                  .split(" ")
                  .map(String::trim)
                  .filter(String::isNotEmpty)
                  .toSet()
        }
        .associate { it }
  }

  fun parseInput(rawInput: List<String>): Set<Pair<String, String>> {
    val mapping = parseRawInput(rawInput)
    return mapping.flatMap { entry -> entry.value.map { entry.key to it } }.toSet()
  }

  private fun partOneHelper(
      connections: Set<Pair<String, String>>
  ): Pair<Set<Set<String>>, List<Pair<String, String>>> {
    val vertices = mutableSetOf<Set<String>>()
    for (connection in connections) {
      for (node in arrayOf(connection.first, connection.second)) {
        val hasNode = vertices.find { it.contains(node) } != null
        if (!hasNode) {
          vertices.add(setOf(node))
        }
      }
    }

    val edges = connections.toMutableList()

    while (vertices.size > 2) {
      val randomEdgeIndex = Random.nextInt(edges.size)
      val randomEdge = edges.removeAt(randomEdgeIndex)
      val subsetA = vertices.find { it.contains(randomEdge.first) }!!
      val subsetB = vertices.find { it.contains(randomEdge.second) }!!
      if (subsetA != subsetB) {
        vertices.remove(subsetA)
        vertices.remove(subsetB)
        val newSubset = subsetA + subsetB
        vertices.add(newSubset)
        val edgesToRemove =
            edges.filter { newSubset.contains(it.first) && newSubset.contains(it.second) }
        edges.removeAll(edgesToRemove)
      }
    }

    return vertices to edges
  }

  fun partOne(connections: Set<Pair<String, String>>): Int {
    var tries = 0
    while (true) {
      val result = partOneHelper(connections)
      tries++
      if (tries % 50 == 0) {
        println("Random algorithms are slow. $tries tries so far...")
      }
      if (result.second.size == 3) {
        return result.first.map { it.size }.reduce { acc, i -> acc * i }
      }
    }
  }
}

fun main() {
  val input = readFileAsList("25/input").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${Day25.partOne(Day25.parseInput(input))}")
}
