import Utils.readFileAsList
import java.util.*

private object Day23 {

  data class Coordinate(val x: Int, val y: Int) {

    private fun isWall(input: List<String>, coordinate: Coordinate): Boolean {
      return input[coordinate.y][coordinate.x] == '#'
    }

    fun getNeighbors(input: List<String>): List<Coordinate> {
      val maybeNeighbors =
          when (input[y][x]) {
            '>' -> listOf(Coordinate(x + 1, y))
            'v' -> listOf(Coordinate(x, y + 1))
            '<' -> listOf(Coordinate(x - 1, y))
            '^' -> listOf(Coordinate(x, y - 1))
            '.' ->
                listOf(
                    Coordinate(x + 1, y),
                    Coordinate(x - 1, y),
                    Coordinate(x, y - 1),
                    Coordinate(x, y + 1))
            else -> error("Unrecognized character ${input[y][x]}")
          }
      return maybeNeighbors.filter { !isWall(input, it) }
    }
  }

  private fun fatDFS(start: Coordinate, end: Coordinate, input: List<String>) {
    val visited = mutableSetOf<Coordinate>()
    val stack = mutableListOf(start)
    //    val parents = mutableMapOf<Coordinate, Coordinate>
    //    while (stack.isNotEmpty()) {
    //
    //    }
  }

  fun partOne(input: List<String>) {
    val start = Coordinate(0, 1)
    val visited = mutableSetOf<Coordinate>(start)
    val queue = LinkedList<Coordinate>()
    queue.add(start)
    //    while (queue.isNotEmpty()) {
    //
    //    }
  }

  fun partTwo(input: List<String>) {
    // TODO("Not yet implemented")
  }
}

fun main() {
  val input = readFileAsList("23/demo").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${Day23.partOne(input)}")
  println("Part 2: ${Day23.partTwo(input)}")
}
