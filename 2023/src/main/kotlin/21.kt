import Utils.readFileAsList

private object Day21 {

  private const val WALL = '#'
  private const val START = 'S'

  data class Coordinate(val x: Int, val y: Int) {
    fun getNeighbors(input: List<String>, repeatable: Boolean = false): List<Coordinate> {
      if (repeatable) {
        return listOfNotNull(
          if (input[y.mod(input.size)][(x - 1).mod(input[0].length)] != WALL) Coordinate(x - 1, y) else null,
          if (input[y.mod(input.size)][(x + 1).mod(input[0].length)] != WALL) Coordinate(x + 1, y) else null,
          if (input[(y - 1).mod(input.size)][x.mod(input[0].length)] != WALL) Coordinate(x, y - 1) else null,
          if (input[(y + 1).mod(input.size)][x.mod(input[0].length)] != WALL) Coordinate(x, y + 1) else null,
        )
      }
      return listOfNotNull(
        if (x > 0 && input[y][x - 1] != WALL) Coordinate(x - 1, y) else null,
        if (x < input[0].length - 1 && input[y][x + 1] != WALL) Coordinate(x + 1, y) else null,
        if (y > 0 && input[y - 1][x] != WALL) Coordinate(x, y - 1) else null,
        if (y < input.size - 1 && input[y + 1][x] != WALL) Coordinate(x, y + 1) else null,
      )
    }
  }

  private fun getStart(input: List<String>): Coordinate {
    for (y in input.indices) {
      for (x in input[0].indices) {
        val char = input[y][x]
        if (char == START) {
          return Coordinate(x, y)
        }
      }
    }
    error("Could not find 'S'")
  }

  fun partOne(input: List<String>): Int {
    val start = getStart(input)
    var lastAdded = listOf(start)
    val visitedOdd = mutableSetOf<Coordinate>()
    val visitedEven = mutableSetOf<Coordinate>()
    for (i in 1..64) {
      val toAddTo = if (i % 2 == 0) visitedEven else visitedOdd
      val newAdds = mutableListOf<Coordinate>()
      for (coordinate in lastAdded) {
        val neighbors = coordinate.getNeighbors(input, false)
        for (neighbor in neighbors) {
          if (!visitedOdd.contains(neighbor) && !visitedEven.contains(neighbor)) {
            newAdds.add(neighbor)
            toAddTo.add(neighbor)
          }
        }
      }
      lastAdded = newAdds
    }
    return visitedEven.size
  }

  fun partTwo(input: List<String>) {
    // TODO("Not yet implemented")
  }
}

fun main() {
  val input = readFileAsList("21/demo").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${Day21.partOne(input)}")
  println("Part 2: ${Day21.partTwo(input)}")
}
