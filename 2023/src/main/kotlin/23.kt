import Utils.readFileAsList
import java.lang.Integer.max

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
      if (rawChar !in SAFE_CHARS) {
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

    companion object {
      const val SAFE_CHARS = ">v<^."
    }
  }

  fun partOne(input: List<String>): Int {
    val start = Coordinate(1, 0)
    val end = Coordinate(input[0].length - 2, input.size - 1)
    val intersectionMap = getIntersections(start, end, input, false)
    return findLongestPathV3(start, end, intersectionMap, 0, setOf(start), start)
  }

  fun partTwo(input: List<String>): Int {
    val start = Coordinate(1, 0)
    val end = Coordinate(input[0].length - 2, input.size - 1)
    val intersectionMap = getIntersections(start, end, input, true)
    return findLongestPathV3(start, end, intersectionMap, 0, setOf(start), start)
  }

  data class Intersection(val coordinate: Coordinate, val distance: Int)

  private fun getIntersections(
    start: Coordinate,
    end: Coordinate,
    input: List<String>,
    ignoreSlopes: Boolean
  ): Map<Coordinate, List<Intersection>> {
    val intersections = mutableSetOf<Coordinate>()
    intersections.add(start)
    intersections.add(end)
    for (y in input.indices) {
      for (x in input[0].indices) {
        val char = input[y][x]
        if (char in Coordinate.SAFE_CHARS) {
          val coordinate = Coordinate(x, y)
          if (coordinate.getNeighbors(input, ignoreSlopes).size > 2) {
            intersections.add(coordinate)
          }
        }
      }
    }

    val intersectionMap = mutableMapOf<Coordinate, MutableList<Intersection>>()

    for (intersection in intersections) {
      val visited = mutableSetOf(intersection)
      var distance = 0
      var queue = setOf(intersection)
      while (queue.isNotEmpty()) {
        distance++
        val nextQueue = mutableSetOf<Coordinate>()
        for (node in queue) {
          val neighbors = node.getNeighbors(input, ignoreSlopes).filter { !visited.contains(it) }
          for (neighbor in neighbors) {
            if (neighbor in intersections) {
              val iMapValue = intersectionMap.getOrPut(intersection) { mutableListOf() }
              iMapValue.add(Intersection(neighbor, distance))
            } else {
              nextQueue.add(neighbor)
              visited.add(neighbor)
            }
          }
        }
        queue = nextQueue
      }
    }

    return intersectionMap
  }

  private fun findLongestPathV3(
    start: Coordinate,
    end: Coordinate,
    intersectionMap: Map<Coordinate, List<Intersection>>,
    distance: Int,
    visited: Set<Coordinate>,
    current: Coordinate,
  ): Int {
    if (current == end) {
      return distance
    }
    var longestPath = Int.MIN_VALUE
    val newVisited = visited + current
    for (intersection in intersectionMap[current]!!) {
      if (!visited.contains(intersection.coordinate)) {
        longestPath = max(
          longestPath,
          findLongestPathV3(
            start,
            end,
            intersectionMap,
            distance + intersection.distance,
            newVisited,
            intersection.coordinate,
          )
        )
      }
    }
    return longestPath
  }
}

fun main() {
  val input = readFileAsList("23/input").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${Day23.partOne(input)}")
  println("Part 2: ${Day23.partTwo(input)}")
}
