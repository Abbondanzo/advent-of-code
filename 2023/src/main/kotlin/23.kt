import Utils.readFileAsList
import java.lang.Integer.max
import java.util.*

private object Day23 {

  data class Coordinate(val x: Int, val y: Int) {

    private fun isWall(input: List<String>, coordinate: Coordinate): Boolean {
      return input[coordinate.y][coordinate.x] == '#'
    }

    fun getNeighbors(input: List<String>, ignoreSlopes: Boolean): List<Coordinate> {
      val rawChar = input[y][x]
      if (rawChar !in ">v<^.") {
        error("Unrecognized character ${input[y][x]} $y $x")
      }
      val maybeNeighbors = if (ignoreSlopes) {
        listOf(
          Coordinate(x + 1, y),
          Coordinate(x - 1, y),
          Coordinate(x, y - 1),
          Coordinate(x, y + 1)
        )
      } else {
        when (rawChar) {
          '>' -> listOf(Coordinate(x + 1, y))
          'v' -> listOf(Coordinate(x, y + 1))
          '<' -> listOf(Coordinate(x - 1, y))
          '^' -> listOf(Coordinate(x, y - 1))
          '.' ->
            listOf(
              Coordinate(x + 1, y),
              Coordinate(x - 1, y),
              Coordinate(x, y - 1),
              Coordinate(x, y + 1)
            )

          else -> error("Unrecognized character ${input[y][x]} $y $x")
        }
      }
      return maybeNeighbors.filter { it.x in input[0].indices && it.y in input.indices && !isWall(input, it) }
    }
  }

  private fun findLongestPath(input: List<String>, ignoreSlopes: Boolean): Int {
    val start = Coordinate(1, 0)
    val end = Coordinate(input[0].length - 2, input.size - 1)
    val parents = mutableMapOf<Coordinate, Pair<Coordinate, Int>>()
    parents[start] = Coordinate(0, 0) to 0
    fun containsCycle(node: Coordinate, neighbor: Coordinate): Boolean {
      var cur = parents[node]?.first
      while (cur != null) {
        if (cur == neighbor) {
          return true
        }
        cur = parents[cur]?.first
      }
      return false
    }

    val queue = LinkedList<Coordinate>()
    queue.add(start)
    while (queue.isNotEmpty()) {
      val node = queue.poll()
      val distance = parents[node]?.second ?: 0
      for (neighbor in node.getNeighbors(input, ignoreSlopes)) {
        val maybeParent = parents[neighbor]
        if (maybeParent == null || (maybeParent.second <= distance && !containsCycle(node, neighbor))) {
          parents[neighbor] = node to distance + 1
          queue.add(neighbor)
        }
      }
    }

//    val toPrint = input.toMutableList()
//    var cur: Coordinate? = end
//    var count = 0
//    while (cur != null) {
//      val coordinate = cur!!
//      toPrint[coordinate.y] = toPrint[coordinate.y].replaceRange(coordinate.x, coordinate.x + 1, "${count % 10}")
//      cur = parents[cur]?.first
//      count++
//    }
//    for (line in toPrint) {
//      println(line)
//    }

    return parents[end]!!.second
  }

  private fun findLongestPathV2(
    input: List<String>,
    visited: Set<Coordinate>,
    current: Coordinate,
    distance: Int,
  ): Int {
    val end = Coordinate(input[0].length - 2, input.size - 1)
    if (current == end) {
      return distance
    }
    var longestPath = Int.MIN_VALUE
    val newVisited = visited + current
    for (neighbor in current.getNeighbors(input, true)) {
      longestPath = max(longestPath, findLongestPathV2(input, newVisited, neighbor, distance + 1))
    }
    return longestPath
  }

  fun partOne(input: List<String>): Int {
    return findLongestPath(input, false)
  }

  fun partTwo(input: List<String>): Int {
    return findLongestPath(input, true)
  }
}

fun main() {
  val input = readFileAsList("23/demo").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${Day23.partOne(input)}")
  println("Part 2: ${Day23.partTwo(input)}")
}
