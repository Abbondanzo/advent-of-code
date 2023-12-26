import Utils.readFileAsList
import java.lang.Integer.max
import java.util.*

private object Day23 {

  data class Coordinate(val x: Int, val y: Int) {

    override fun toString(): String {
      return "($x,$y)"
    }

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

  private data class Edge(val from: Coordinate, val to: Coordinate)

  private fun findLongestPath(input: List<String>, ignoreSlopes: Boolean): Int {
    val start = Coordinate(1, 0)
    val end = Coordinate(input[0].length - 2, input.size - 1)
    val paths = mutableMapOf<Coordinate, MutableList<Set<Coordinate>>>()
    paths[start] = mutableListOf(setOf(start))
    fun containsCycle(path: Set<Coordinate>, neighbor: Coordinate): Boolean {
      return path.contains(neighbor)
    }
    val queue = LinkedList<Coordinate>()
    queue.add(start)
    while (queue.isNotEmpty()) {
      val node = queue.poll()
      println("$node ${paths[node]?.size}")
      val currentPaths = paths[node] ?: mutableListOf()
      for (neighbor in node.getNeighbors(input, ignoreSlopes)) {
        val neighborPaths = paths.getOrPut(neighbor) { mutableListOf() }
        for (path in currentPaths) {
          if (!containsCycle(path, neighbor)) {
            neighborPaths.add(path + neighbor)
            queue.add(neighbor)
          }
        }
      }
    }

    val endPaths = paths[end]
    println(endPaths?.map { it.size })

//    for (edge in paths[Edge(Coordinate(11, 4), Coordinate(11, 3))] ?: setOf()) {
//      println(edge)
//    }

//    val toPrint = input.toMutableList()
//    for (edge in endPath) {
//      toPrint[edge.from.y] = toPrint[edge.from.y].replaceRange(edge.from.x, edge.from.x + 1, "O")
//    }
//    for (line in toPrint) {
//      println(line)
//    }

    return 0
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
//  println("Part 1: ${Day23.partOne(input)}")
  println("Part 2: ${Day23.partTwo(input)}")
}
