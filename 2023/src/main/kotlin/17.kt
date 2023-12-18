import Utils.readFileAsList
import java.util.*

private object Day17 {

  enum class Direction {
    UP,
    DOWN,
    LEFT,
    RIGHT;

    fun inverted(other: Direction): Boolean {
      return when (this) {
        UP -> other == DOWN
        DOWN -> other == UP
        LEFT -> other == RIGHT
        RIGHT -> other == LEFT
      }
    }
  }

  data class Coordinate(val x: Int, val y: Int)

  data class MapKey(
      val coordinate: Coordinate,
      val stepsInDirection: Int,
      val direction: Direction
  )

  private fun getNeighbors(
      input: List<List<Int>>,
      current: MapKey,
      maxStepsInDirection: Int,
      minStepsInDirection: Int? = null
  ): List<MapKey> {
    val coordinate = current.coordinate
    val unfilteredNeighbors =
        listOf(
                MapKey(Coordinate(coordinate.x - 1, coordinate.y), 0, Direction.LEFT),
                MapKey(Coordinate(coordinate.x + 1, coordinate.y), 0, Direction.RIGHT),
                MapKey(Coordinate(coordinate.x, coordinate.y - 1), 0, Direction.UP),
                MapKey(Coordinate(coordinate.x, coordinate.y + 1), 0, Direction.DOWN),
            )
            .map {
              val steps = if (it.direction == current.direction) current.stepsInDirection + 1 else 1
              it.copy(stepsInDirection = steps)
            }
    return unfilteredNeighbors.filter { neighbor ->
      val validCoordinates =
          neighbor.coordinate.x in input[0].indices && neighbor.coordinate.y in input.indices
      if (!validCoordinates) {
        return@filter false
      }
      if (current.direction.inverted(neighbor.direction)) {
        return@filter false
      }
      if (minStepsInDirection != null && current.stepsInDirection < minStepsInDirection) {
        return@filter neighbor.direction == current.direction
      }
      return@filter neighbor.stepsInDirection <= maxStepsInDirection
    }
  }

  private fun findSmallestDistance(
      input: List<List<Int>>,
      maxStepsInDirection: Int,
      minStepsInDirection: Int?
  ): Int {
    val endX = input[0].size - 1
    val endY = input.size - 1

    val distances = mutableMapOf<MapKey, Int>()
    val cameFrom = mutableMapOf<MapKey, MapKey>()

    distances[MapKey(Coordinate(1, 0), 1, Direction.RIGHT)] = input[0][1]
    distances[MapKey(Coordinate(0, 1), 1, Direction.DOWN)] = input[1][0]

    val queue =
        PriorityQueue<MapKey> { a, b ->
          distances
              .getOrDefault(a, Int.MAX_VALUE)
              .compareTo(distances.getOrDefault(b, Int.MAX_VALUE))
        }
    queue.addAll(distances.keys)

    while (queue.isNotEmpty()) {
      val current = queue.poll()
      for (neighbor in getNeighbors(input, current, maxStepsInDirection, minStepsInDirection)) {
        val tentativeDistance =
            distances[current]!! + input[neighbor.coordinate.y][neighbor.coordinate.x]
        if (tentativeDistance < distances.getOrDefault(neighbor, Int.MAX_VALUE)) {
          cameFrom[neighbor] = current
          distances[neighbor] = tentativeDistance
          queue.add(neighbor)
        }
      }
    }
    val endDistances =
        distances.filterKeys { key ->
          if (minStepsInDirection != null && key.stepsInDirection < minStepsInDirection) {
            return@filterKeys false
          }
          key.coordinate.x == endX && key.coordinate.y == endY
        }
    return endDistances.values.toList().min()
  }

  fun partOne(input: List<List<Int>>): Int {
    return findSmallestDistance(input, 3, null)
  }

  fun partTwo(input: List<List<Int>>): Int {
    return findSmallestDistance(input, 10, 4)
  }
}

fun main() {
  val input = readFileAsList("17/input").map(String::trim).filter(String::isNotEmpty)
  val heatMap = input.map { row -> row.map { it.toString().toInt() } }
  println("Part 1: ${Day17.partOne(heatMap)}")
  println("Part 2: ${Day17.partTwo(heatMap)}")
}
