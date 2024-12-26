import Utils.readFileAsList
import Utils.Pos
import kotlin.math.absoluteValue

private class FestivalBoard(
  val start: Pos,
  val end: Pos,
  val walls: Set<Pos>,
  val board: List<String>,
)

private fun parseInput(lines: List<String>): FestivalBoard {
  var start: Pos? = null
  var end: Pos? = null
  val walls = mutableSetOf<Pos>()
  for ((rowIndex, row) in lines.withIndex()) {
    for ((colIndex, char) in row.withIndex()) {
      when (char) {
        'S' -> start = Pos(rowIndex, colIndex)
        'E' -> end = Pos(rowIndex, colIndex)
        '#' -> walls.add(Pos(rowIndex, colIndex))
      }
    }
  }
  return FestivalBoard(
    start = start ?: error("No start found"),
    end = end ?: error("No end found"),
    walls = walls,
    board = lines,
  )
}

private fun computeVisited(board: FestivalBoard): Map<Pos, Int> {
  val queue = mutableListOf<Pair<Pos, Int>>()
  val visited = mutableMapOf<Pos, Int>()
  queue.add(board.start to 0)
  while (queue.isNotEmpty()) {
    val (currentPos, currentDistance) = queue.removeFirst()
    visited.compute(currentPos) { _, oldValue ->
      if (oldValue != null && oldValue < currentDistance) oldValue else currentDistance
    }
    val neighbors = listOf(
      Pos(1, 0),
      Pos(-1, 0),
      Pos(0, 1),
      Pos(0, -1),
    )
      .map { currentPos + it }
      .filter { board.board[it.row][it.col] in ".E" }
    for (neighbor in neighbors) {
      if (!visited.contains(neighbor)) {
        queue.add(neighbor to currentDistance + 1)
      }
    }
  }
  return visited
}

private fun partOne(board: FestivalBoard): Int {
  val visited = computeVisited(board)
  val offsets = mutableListOf<Pos>()
  for (rowOffset in -2..2) {
    val colOffset = 2 - rowOffset.absoluteValue
    offsets.add(Pos(rowOffset, colOffset))
    offsets.add(Pos(rowOffset, -colOffset))
  }
  val cheats = mutableMapOf<Pair<Pos, Pos>, Int>()
  for ((startingPos, distance) in visited) {
    val destinations = offsets.map { it + startingPos }
    for (destination in destinations)  {
      val otherDistance = visited[destination]
      if (otherDistance != null && otherDistance > distance) {
        val newTime = otherDistance - distance - 2
        cheats[startingPos to destination] = newTime
      }
    }
  }
  val groups = cheats.filter { it.value > 0 }.values.groupBy { it }.mapValues { it.value.size }
  var total = 0
  for ((cheatSavings, count) in groups) {
    if (cheatSavings >= 100) {
      total += count
    }
  }
  return total
}

private fun partTwo(board: FestivalBoard): Int {
  val visited = computeVisited(board)
  val cheats = mutableMapOf<Pair<Pos, Pos>, Int>()
  for ((startingPos, startingDistance) in visited) {
    for ((destinationPos, destinationDistance) in visited) {
      if (startingPos != destinationPos) {
        val manhattanDistance = (startingPos.col - destinationPos.col).absoluteValue + (startingPos.row - destinationPos.row).absoluteValue
        if (manhattanDistance <= 20 && destinationDistance > startingDistance) {
          val newTime = destinationDistance - startingDistance - manhattanDistance
          cheats[startingPos to destinationPos] = newTime
        }
      }
    }
  }
  val groups = cheats.filter { it.value > 0 }.values.groupBy { it }.mapValues { it.value.size }
  var total = 0
  for ((cheatSavings, count) in groups) {
    if (cheatSavings >= 100) {
      total += count
    }
  }
  return total
}

fun main() {
  val lines = readFileAsList("20/input").filter { it.isNotEmpty() }
  val board = parseInput(lines)
  println("Part 1: ${partOne(board)}")
  println("Part 2: ${partTwo(board)}")
}
