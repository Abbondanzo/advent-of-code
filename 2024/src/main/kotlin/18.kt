import Utils.readFileAsList
import Utils.Pos

private data class Board(
  val dimension: Int,
  val corruption: List<Pos>,
)

private fun partOne(input: Board): Int {
  val start = Pos(0, 0)
  val end = Pos(input.dimension, input.dimension)
  val queue = mutableListOf<Pair<Pos, Int>>()
  val visited = mutableSetOf<Pos>()
  val walls = input.corruption.toSet()
  val validDimension = 0..input.dimension
  queue.add(start to 0)
  while (queue.isNotEmpty()) {
    val (currentPos, currentDistance) = queue.removeFirst()
    if (currentPos == end) {
      return currentDistance
    }
    visited.add(currentPos)
    val neighbors = listOf(
      Pos(1, 0),
      Pos(-1, 0),
      Pos(0, 1),
      Pos(0, -1),
    )
      .map { it + currentPos }
      .filter { it.col in validDimension && it.row in validDimension }
    for (neighbor in neighbors) {
      if (walls.contains(neighbor) || visited.contains(neighbor)) {
        continue
      }
      val newDistance = currentDistance + 1
      val inQueue = queue.any { it.first == neighbor && it.second <= newDistance }
      if (!inQueue) {
        queue.add(neighbor to newDistance)
      }
    }
  }
  return -1
}

private fun partTwo(input: Board, truncationSize: Int): String {
  var badSize = truncationSize
  while (badSize < input.corruption.size) {
    val truncatedInput = input.copy(corruption = input.corruption.take(badSize))
    if (partOne(truncatedInput) == -1) {
      break
    }
    badSize++
  }
  val badItem = input.corruption[badSize - 1]
  return "${badItem.col},${badItem.row}"
}

fun main() {
  val demo = false
  val lines = if (demo) readFileAsList("18/demo") else readFileAsList("18/input")
  val corruption = lines.filter { it.isNotEmpty() }.map { line ->
    val (col, row) = line.split(",").map(String::toInt)
    Pos(row, col)
  }
  val input = Board(
    dimension = if (demo) 6 else 70,
    corruption = corruption,
  )
  val truncationSize = if (demo) 12 else 1024
  val truncatedInput = input.copy(
    corruption = corruption.take(truncationSize),
  )
  println("Part 1: ${partOne(truncatedInput)}")
  println("Part 2: ${partTwo(input, truncationSize)}")
}
