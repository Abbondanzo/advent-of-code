import Utils.readFileAsList
import java.util.*
import kotlin.math.absoluteValue

private class Day17 {

  enum class Direction {
    UP,
    DOWN,
    LEFT,
    RIGHT,
    START;

    fun inverted(other: Direction): Boolean {
      return when (this) {
        UP -> other == DOWN
        DOWN -> other == UP
        LEFT -> other == RIGHT
        RIGHT -> other == LEFT
        else -> false
      }
    }
  }

  data class Coordinate(val x: Int, val y: Int, val direction: Direction) {
    fun getPrevious(distance: Int): List<Coordinate> {
      val xStep =
          when (direction) {
            Direction.UP,
            Direction.DOWN,
            Direction.START -> 0
            Direction.LEFT -> 1
            Direction.RIGHT -> -1
          }
      val yStep =
          when (direction) {
            Direction.LEFT,
            Direction.RIGHT,
            Direction.START -> 0
            Direction.DOWN -> -1
            Direction.UP -> 1
          }
      return (1..distance).map { offset ->
        Coordinate(x + (xStep * offset), y + (yStep * offset), direction)
      }
    }
  }

  private fun manhattanDistance(a: Coordinate, b: Coordinate): Int {
    return (a.x - b.x).absoluteValue + (a.y - b.y).absoluteValue
  }

  private fun getPrevious(
      current: Coordinate,
      distance: Int,
      cameFrom: Map<Coordinate, Coordinate>
  ): List<Coordinate> {
    val previous = mutableListOf<Coordinate>()
    var prev = cameFrom.getOrDefault(current, null)
    while (prev != null && previous.size < distance) {
      previous.add(prev)
      prev = cameFrom.getOrDefault(prev, null)
    }
    return previous
  }

  private fun isLegalDirection(
      distance: Int,
      direction: Direction,
      current: Coordinate,
      cameFrom: Map<Coordinate, Coordinate>
  ): Boolean {
    if (current.direction != direction) {
      return true
    }
    var countDirection = 1
    var prev = cameFrom.getOrDefault(current, null)
    while (prev != null) {
      if (prev.direction != direction) {
        break
      }
      countDirection++
      if (countDirection >= distance) {
        return false
      }
      prev = cameFrom.getOrDefault(prev, null)
    }
    return true
  }

  private fun getNeighbors(
      input: List<List<Int>>,
      cameFrom: Map<Coordinate, Coordinate>,
      current: Coordinate
  ): List<Coordinate> {
    val unfilteredNeighbors =
        listOf(
            Coordinate(current.x - 1, current.y, Direction.LEFT),
            Coordinate(current.x + 1, current.y, Direction.RIGHT),
            Coordinate(current.x, current.y - 1, Direction.UP),
            Coordinate(current.x, current.y + 1, Direction.DOWN),
        )
    return unfilteredNeighbors.filter { neighbor ->
      !current.direction.inverted(neighbor.direction) &&
          neighbor.x in input[0].indices &&
          neighbor.y in input.indices &&
          isLegalDirection(3, neighbor.direction, current, cameFrom)
    }
  }

  private fun reconstructPath(
      input: List<List<Int>>,
      current: Coordinate,
      cameFrom: Map<Coordinate, Coordinate>
  ): Int {
    var total = 0
    var cur: Coordinate? = current
    while (cur != null && cur in cameFrom.keys) {
      println(cur)
      total += input[cur.y][cur.x]
      cur = cameFrom[cur]
    }
    return total
  }

  //  fun partOneBad(input: List<List<Int>>): Int {
  //    val start = Coordinate(0, 0)
  //    val end = Coordinate(input[0].size - 1, input.size - 1)
  //
  //    val queue =
  //        PriorityQueue<Coordinate> { a, b ->
  //          manhattanDistance(a, end).compareTo(manhattanDistance(b, end))
  //        }
  //    queue.add(start)
  //    val cameFrom = mutableMapOf<Coordinate, Coordinate>()
  //    val gScore = mutableMapOf<Coordinate, Int>()
  //    gScore[start] = 0
  //    val fScore = mutableMapOf<Coordinate, Int>()
  //    fScore[start] = manhattanDistance(start, end)
  //
  //    while (queue.isNotEmpty()) {
  //      val current = queue.poll()
  //      if (current == end) {
  //        return reconstructPath(input, current, cameFrom)
  //      }
  //      val neighbors = getNeighbors(input, cameFrom, current)
  //      println("$current $neighbors")
  //      for (neighbor in getNeighbors(input, cameFrom, current)) {
  //        val tentativeGScore = gScore[current]!! + input[neighbor.y][neighbor.x]
  //        val neighborScore = gScore.getOrDefault(neighbor, null)
  //        if (neighborScore == null || tentativeGScore < neighborScore) {
  //          cameFrom[neighbor] = current
  //          gScore[neighbor] = tentativeGScore
  //          fScore[neighbor] = tentativeGScore + manhattanDistance(neighbor, end)
  //          if (!queue.contains(neighbor)) {
  //            queue.add(neighbor)
  //          }
  //        }
  //      }
  //    }
  //
  //    error("BEANS")
  //  }

  fun partOne(input: List<List<Int>>): Int {
    val start = Coordinate(0, 0, Direction.START)
    val endX = input[0].size - 1
    val endY = input.size - 1

    val distances = mutableMapOf<Coordinate, Int>()
    val cameFrom = mutableMapOf<Coordinate, Coordinate>()

    val queue =
        PriorityQueue<Coordinate> { a, b ->
          distances
              .getOrDefault(a, Int.MAX_VALUE)
              .compareTo(distances.getOrDefault(b, Int.MAX_VALUE))
        }
    queue.add(start)
    distances[start] = input[0][0]

    while (queue.isNotEmpty()) {
      val current = queue.poll()
      //      if (current.x == endX && current.y == endY) {
      //        distances.entries.map { println(it) }
      //        cameFrom.entries.map { println(it) }
      //        return distances[current]!!
      //      }
      val neighbors = getNeighbors(input, cameFrom, current)
      //      println("$current $neighbors")
      for (neighbor in getNeighbors(input, cameFrom, current)) {
        val tentativeDistance = distances[current]!! + input[neighbor.y][neighbor.x]
        //        if (neighbor.x == 2 && neighbor.y == 1) {
        //          println("$current ${distances[current]} $tentativeDistance
        // ${distances.getOrDefault(neighbor, Int.MAX_VALUE)}")
        //        }
        if (tentativeDistance < distances.getOrDefault(neighbor, Int.MAX_VALUE)) {
          cameFrom[neighbor] = current
          distances[neighbor] = tentativeDistance
          queue.add(neighbor)
        }
      }
    }

    val endDistances =
        distances.filterKeys { coordinate -> coordinate.x == endX && coordinate.y == endY }
    cameFrom.entries.map { println("$it ${distances.get(it.key)}") }

    endDistances.forEach {
      println("\n\n\n\n $it")
      reconstructPath(input, it.key, cameFrom)
    }

    error("BEANS")
  }
}

private fun partTwo(input: List<String>) {
  TODO("Not yet implemented")
}

fun main() {
  val input = readFileAsList("17/demo").map(String::trim).filter(String::isNotEmpty)
  val heatMap = input.map { row -> row.map { it.toString().toInt() } }
  println("Part 1: ${Day17().partOne(heatMap)}")
  //  println("Part 2: ${partTwo(input)}")
}
