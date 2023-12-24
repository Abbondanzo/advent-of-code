import Utils.readFileAsList

private object Day21 {

  private const val WALL = '#'
  private const val START = 'S'

  data class Coordinate(val x: Int, val y: Int) {
    fun getNeighbors(input: List<String>, repeatable: Boolean = false): List<Coordinate> {
      if (repeatable) {
        return listOfNotNull(
            if (input[y.mod(input.size)][(x - 1).mod(input[0].length)] != WALL) Coordinate(x - 1, y)
            else null,
            if (input[y.mod(input.size)][(x + 1).mod(input[0].length)] != WALL) Coordinate(x + 1, y)
            else null,
            if (input[(y - 1).mod(input.size)][x.mod(input[0].length)] != WALL) Coordinate(x, y - 1)
            else null,
            if (input[(y + 1).mod(input.size)][x.mod(input[0].length)] != WALL) Coordinate(x, y + 1)
            else null,
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

  private fun solveDiamond(input: List<String>, repeatable: Boolean, steps: Int): Int {
    val start = getStart(input)
    var lastAdded = listOf(start)
    val visitedOdd = mutableSetOf<Coordinate>()
    val visitedEven = mutableSetOf<Coordinate>()
    for (i in 1..steps) {
      val toAddTo = if (i % 2 == 0) visitedEven else visitedOdd
      val newAdds = mutableListOf<Coordinate>()
      for (coordinate in lastAdded) {
        val neighbors = coordinate.getNeighbors(input, repeatable)
        for (neighbor in neighbors) {
          if (!visitedOdd.contains(neighbor) && !visitedEven.contains(neighbor)) {
            newAdds.add(neighbor)
            toAddTo.add(neighbor)
          }
        }
      }
      lastAdded = newAdds
    }
    return if (steps % 2 == 0) visitedEven.size else visitedOdd.size
  }

  fun partOne(input: List<String>): Int {
    return solveDiamond(input, false, 64)
  }

  private fun lag(input: Triple<Long, Long, Long>): Triple<Long, Long, Long> {
    return Triple(
        input.first / 2 - input.second + input.third / 2,
        -3 * (input.first / 2) + 2 * input.second - input.third / 2,
        input.first)
  }

  fun partTwo(input: List<String>): Long {
    assert(input[0].length == input.size)
    val middle = Coordinate(input[0].length / 2, input.size / 2)
    assert(input[middle.y][middle.x] == 'S')
    // The pattern repeats itself every 131 steps, with an offset of 65 from the center
    val results = (0..2).map { it * 131 + 65 }.map { solveDiamond(input, true, it).toLong() }
    val lg = lag(Triple(results[0], results[1], results[2]))
    // Count how many real "steps" we have to reach larger count
    val stepper = ((26501365 - 65) / 131).toLong()
    return lg.first * stepper * stepper + lg.second * stepper + lg.third
  }
}

fun main() {
  val input = readFileAsList("21/input").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${Day21.partOne(input)}")
  println("Part 2: ${Day21.partTwo(input)}")
}
