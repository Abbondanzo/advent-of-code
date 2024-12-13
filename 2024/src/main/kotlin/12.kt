import Utils.Pos
import Utils.readFileAsList

private data class Region(
    val letter: Char,
    val positions: Set<Pos>,
) {
  override fun toString(): String {
    return "Region($letter, ${positions.size})"
  }
}

private fun Pos.getNeighbors(): List<Pos> {
  return listOf(
      // Up
      Pos(row - 1, col),
      // Down
      Pos(row + 1, col),
      // Left
      Pos(row, col - 1),
      // Right
      Pos(row, col + 1),
  )
}

private fun Pos.isInBounds(input: List<String>): Boolean {
  return row in input.indices && col in input.first().indices
}

private fun Pos.getValidNeighbors(input: List<String>): List<Pos> {
  return getNeighbors().filter { it.isInBounds(input) }
}

private fun buildRegion(start: Pos, lines: List<String>): Region {
  val queue = mutableListOf<Pos>()
  queue.add(start)
  val char = lines[start.row][start.col]
  val positions = mutableSetOf<Pos>()
  while (queue.isNotEmpty()) {
    val nextPos = queue.removeFirst()
    positions.add(nextPos)
    val positionsToCheck = nextPos.getValidNeighbors(lines)
    positionsToCheck.forEach {
      if (!positions.contains(it) && lines[it.row][it.col] == char) {
        positions.add(it)
        queue.add(it)
      }
    }
  }
  return Region(
      letter = char,
      positions = positions,
  )
}

private fun buildRegions(lines: List<String>): List<Region> {
  val regionsToCheck = mutableSetOf<Pos>()
  for ((rowIndex, row) in lines.withIndex()) {
    for (colIndex in row.indices) {
      regionsToCheck.add(Pos(rowIndex, colIndex))
    }
  }
  val regions = mutableListOf<Region>()
  while (regionsToCheck.isNotEmpty()) {
    val region = buildRegion(regionsToCheck.first(), lines)
    regions.add(region)
    regionsToCheck.removeAll(region.positions)
  }
  return regions
}

private fun partOne(lines: List<String>): Int {
  val regions = buildRegions(lines)
  var total = 0
  regions.forEach { region ->
    var fences = 0
    for (pos in region.positions) {
      for (neighbor in pos.getNeighbors()) {
        if (!neighbor.isInBounds(lines) || lines[neighbor.row][neighbor.col] != region.letter) {
          fences++
        }
      }
    }
    total += region.positions.size * fences
  }
  return total
}

private fun checkAndAdd(pos: Pos, letter: Char, list: MutableList<Pos>, lines: List<String>) {
  if (!pos.isInBounds(lines) || lines[pos.row][pos.col] != letter) {
    list.add(pos)
  }
}

private fun getSidesLeftRight(positions: List<Pos>): Int {
  var sides = 0
  var lastRow = Int.MIN_VALUE
  var lastCol = Int.MIN_VALUE
  val leftRightComparator = compareBy(Pos::col).thenBy(Pos::row)
  for (pos in positions.sortedWith(leftRightComparator)) {
    if (lastRow != pos.row - 1 || lastCol != pos.col) {
      sides++
    }
    lastRow = pos.row
    lastCol = pos.col
  }
  return sides
}

private fun getSidesUpDown(positions: List<Pos>): Int {
  var sides = 0
  var lastRow = Int.MIN_VALUE
  var lastCol = Int.MIN_VALUE
  val upDownComparator = compareBy(Pos::row).thenBy(Pos::col)
  for (pos in positions.sortedWith(upDownComparator)) {
    if (lastRow != pos.row || lastCol != pos.col - 1) {
      sides++
    }
    lastRow = pos.row
    lastCol = pos.col
  }
  return sides
}

private fun partTwo(lines: List<String>): Int {
  val regions = buildRegions(lines)
  var total = 0
  regions.forEach { region ->
    val leftFences = mutableListOf<Pos>()
    val rightFences = mutableListOf<Pos>()
    val upFences = mutableListOf<Pos>()
    val downFences = mutableListOf<Pos>()
    for (pos in region.positions) {
      val left = Pos(pos.row, pos.col - 1)
      checkAndAdd(left, region.letter, leftFences, lines)
      val right = Pos(pos.row, pos.col + 1)
      checkAndAdd(right, region.letter, rightFences, lines)
      val up = Pos(pos.row - 1, pos.col)
      checkAndAdd(up, region.letter, upFences, lines)
      val down = Pos(pos.row + 1, pos.col)
      checkAndAdd(down, region.letter, downFences, lines)
    }
    val sides =
        getSidesLeftRight(leftFences) +
            getSidesLeftRight(rightFences) +
            getSidesUpDown(upFences) +
            getSidesUpDown(downFences)
    total += sides * region.positions.size
  }
  return total
}

fun main() {
  val input = readFileAsList("12/input").filter { it.isNotEmpty() }
  println("Part 1: ${partOne(input)}")
  println("Part 2: ${partTwo(input)}")
}
