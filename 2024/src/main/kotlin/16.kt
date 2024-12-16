import Utils.Direction
import Utils.Pos
import Utils.readFileAsList

private fun findStartAndEnd(lines: List<String>): Pair<Pos, Pos> {
  var start: Pos? = null
  var end: Pos? = null
  for ((rowIndex, row) in lines.withIndex()) {
    for ((colIndex, col) in row.withIndex()) {
      if (col == 'S') {
        start = Pos(rowIndex, colIndex)
      } else if (col == 'E') {
        end = Pos(rowIndex, colIndex)
      }
    }
  }
  return start!! to end!!
}

// Basic Dijkstra
private fun partOne(lines: List<String>): Int {
  val (start, end) = findStartAndEnd(lines)
  val visited: MutableMap<Pair<Pos, Direction>, Int> = mutableMapOf()
  val queue = mutableListOf<Pair<Pos, Direction>>()
  queue.add(start to Direction.RIGHT)
  visited[start to Direction.RIGHT] = 0

  while (queue.isNotEmpty()) {
    val (curPos, curDirection) = queue.removeFirst()
    val neighbors =
        listOf(
                // Straight
                Triple(
                    curDirection.applyOffset(curPos),
                    curDirection,
                    1,
                ),
                // Left
                Triple(
                    curDirection.rotateLeft().applyOffset(curPos),
                    curDirection.rotateLeft(),
                    1001,
                ),
                // Right
                Triple(
                    curDirection.rotateRight().applyOffset(curPos),
                    curDirection.rotateRight(),
                    1001,
                ),
            )
            .filter { lines[it.first.row][it.first.col] !in "#S" }
    val curDistance = visited[curPos to curDirection]!!
    var addedToQueue = false
    for (neighbor in neighbors) {
      val newDistance = curDistance + neighbor.third
      val oldDistance = visited.getOrDefault(neighbor.first to neighbor.second, Int.MAX_VALUE)
      if (newDistance < oldDistance) {
        visited[neighbor.first to neighbor.second] = newDistance
        if (neighbor.first != end && !queue.contains(neighbor.first to neighbor.second)) {
          queue.add(neighbor.first to neighbor.second)
          addedToQueue = true
        }
      }
    }
    if (addedToQueue) {
      queue.sortBy { visited.getOrDefault(it, Int.MAX_VALUE) }
    }
  }
  val anyFinds = visited.filter { it.key.first == end }
  if (anyFinds.isEmpty()) error("No finds to end!")
  return anyFinds.minOf { it.value }
}

private data class BestQueueItem(
    val pos: Pos,
    val direction: Direction,
    val path: List<Pos>,
)

private fun partTwo(lines: List<String>): Int {
  val (start, end) = findStartAndEnd(lines)
  val visited: MutableMap<Pair<Pos, Direction>, Int> = mutableMapOf()
  val queue = mutableListOf<BestQueueItem>()
  queue.add(BestQueueItem(start, Direction.RIGHT, listOf(start)))
  visited[start to Direction.RIGHT] = 0
  val finishers = mutableSetOf<Pair<BestQueueItem, Int>>()

  while (queue.isNotEmpty()) {
    val (curPos, curDirection, curPath) = queue.removeFirst()
    val neighbors =
        listOf(
                // Straight
                Triple(
                    curDirection.applyOffset(curPos),
                    curDirection,
                    1,
                ),
                // Left
                Triple(
                    curDirection.rotateLeft().applyOffset(curPos),
                    curDirection.rotateLeft(),
                    1001,
                ),
                // Right
                Triple(
                    curDirection.rotateRight().applyOffset(curPos),
                    curDirection.rotateRight(),
                    1001,
                ),
            )
            .filter { lines[it.first.row][it.first.col] !in "#S" }
    val curDistance = visited[curPos to curDirection]!!
    var addedToQueue = false
    for (neighbor in neighbors) {
      val newDistance = curDistance + neighbor.third
      val oldDistance = visited.getOrDefault(neighbor.first to neighbor.second, Int.MAX_VALUE)
      if (newDistance <= oldDistance) {
        visited[neighbor.first to neighbor.second] = newDistance
        val bqi = BestQueueItem(neighbor.first, neighbor.second, curPath + listOf(neighbor.first))
        if (neighbor.first != end) {
          queue.add(bqi)
          addedToQueue = true
        } else {
          finishers.add(bqi to newDistance)
        }
      }
    }
    if (addedToQueue) {
      queue.sortBy { visited.getOrDefault((it.pos to it.direction), Int.MAX_VALUE) }
    }
  }
  val anyFinds = visited.filter { it.key.first == end }
  if (anyFinds.isEmpty()) error("No finds to end!")
  val bestDistance = anyFinds.minOf { it.value }
  val visitedPos = mutableSetOf<Pos>()
  finishers.filter { it.second == bestDistance }.forEach { visitedPos.addAll(it.first.path) }
  return visitedPos.size
}

fun main() {
  val input = readFileAsList("16/input").filter { it.isNotEmpty() }
  println("Part 1: ${partOne(input)}")
  println("Part 2: ${partTwo(input)}")
}
