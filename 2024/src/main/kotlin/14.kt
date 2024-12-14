import Utils.Pos
import Utils.readFileAsList

private fun partOne(robots: List<Robot>, size: Pos): Int {
  val leftRange = 0..<(size.col / 2)
  val rightRange = (1 + size.col / 2)..<size.col
  val upRange = 0..<(size.row / 2)
  val downRange = (1 + size.row / 2)..<size.row
  // upper-left, upper-right, lower-left, lower-right
  val counts = Array(4) { 0 }
  for (robot in robots) {
    val finalPosition = (robot.initialPos + robot.velocity * 100).mod(size)
    if (finalPosition.row in upRange) {
      if (finalPosition.col in leftRange) {
        counts[0]++
      } else if (finalPosition.col in rightRange) {
        counts[1]++
      }
    } else if (finalPosition.row in downRange) {
      if (finalPosition.col in leftRange) {
        counts[2]++
      } else if (finalPosition.col in rightRange) {
        counts[3]++
      }
    }
  }

  return counts.reduce { acc, i -> acc * i }
}

private fun printBoard(steps: Int, robots: List<Robot>, size: Pos) {
  val finalPositions =
      robots.map { (it.initialPos + it.velocity * steps).mod(size) }.groupBy { it.row }

  for (row in 0..<size.row) {
    val cols = finalPositions[row]?.map { it.col }?.toSet() ?: setOf()
    val sb = StringBuilder()
    for (col in 0..<size.col) {
      if (cols.contains(col)) {
        sb.append("R")
      } else {
        sb.append(".")
      }
    }
    println(sb.toString())
  }
}

private fun getGroupings(positions: Set<Pos>): Int {
  val remainingPositions = mutableSetOf<Pos>()
  remainingPositions.addAll(positions)
  val queue = mutableSetOf<Pos>()
  var maxGrouping = 1
  var currentGrouping = 0
  while (remainingPositions.isNotEmpty()) {
    if (queue.isEmpty()) {
      val first = remainingPositions.first()
      queue.add(first)
      remainingPositions.remove(first)
      currentGrouping = 0
    }
    val first = queue.first()
    currentGrouping++
    if (currentGrouping > maxGrouping) {
      maxGrouping = currentGrouping
    }
    queue.remove(first)
    val neighbors =
        listOf(
            first + Pos(1, 0),
            first + Pos(-1, 0),
            first + Pos(0, 1),
            first + Pos(0, -1),
        )
    for (neighbor in neighbors) {
      if (remainingPositions.contains(neighbor)) {
        queue.add(neighbor)
        remainingPositions.remove(neighbor)
      }
    }
  }
  return maxGrouping
}

private fun partTwo(robots: List<Robot>, size: Pos): Int {
  var i = 1
  var maxGrouping = 20 // Arbitrary grouping count
  while (i < size.row * size.col) {
    val finalPositions = robots.map { (it.initialPos + it.velocity * i).mod(size) }.toSet()
    val groupingSize = getGroupings(finalPositions)
    if (groupingSize > maxGrouping) {
      maxGrouping = groupingSize
      printBoard(i, robots, size)
      println(i)
    }
    i++
  }
  return 0
}

private data class Robot(
    val initialPos: Pos,
    val velocity: Pos,
)

fun main() {
  val robotRegex = Regex("p=(\\d+),(\\d+) v=(-?\\d+),(-?\\d+)")
  val useDemo = false
  val size = if (useDemo) Pos(7, 11) else Pos(103, 101)
  val inputFile = if (useDemo) "14/demo" else "14/input"
  val input = readFileAsList(inputFile).filter { it.isNotEmpty() }
  val robots = mutableListOf<Robot>()
  for (line in input) {
    val groups = robotRegex.find(line)!!.groupValues.takeLast(4).map(String::toInt)
    val initialPos = Pos(groups[1], groups[0])
    val velocity = Pos(groups[3], groups[2])
    robots.add(Robot(initialPos, velocity))
  }

  println("Part 1: ${partOne(robots, size)}")
  println("Part 2: ${partTwo(robots, size)}")
}
