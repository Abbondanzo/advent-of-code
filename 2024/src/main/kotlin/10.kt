import Utils.Pos
import Utils.readFileAsList

private fun List<List<Int>>.getIntAt(pos: Pos): Int {
  return this[pos.row][pos.col]
}

private fun getTrailheadScore(trailhead: Pos, input: List<List<Int>>): Int {
  val queue = mutableListOf<Pos>()
  queue.add(trailhead)
  val reachableNines = mutableSetOf<Pos>()
  val visited = mutableSetOf<Pos>()
  while (queue.isNotEmpty()) {
    val item = queue.removeFirst()
    visited.add(item)
    val itemValue = input.getIntAt(item)
    if (itemValue == 9) {
      reachableNines.add(item)
      continue
    }
    val posToCheck =
        listOf(
            Pos(item.row - 1, item.col),
            Pos(item.row + 1, item.col),
            Pos(item.row, item.col - 1),
            Pos(item.row, item.col + 1),
        )
    posToCheck.forEach { pos ->
      if (pos.row in input.indices && pos.col in input[0].indices) {
        val posValue = input.getIntAt(pos)
        if (itemValue + 1 == posValue && !visited.contains(pos)) {
          queue.add(pos)
        }
      }
    }
  }
  return reachableNines.size
}

private fun partOne(input: List<List<Int>>): Int {
  val trailheads = mutableSetOf<Pos>()
  for ((rowIndex, row) in input.withIndex()) {
    for ((colIndex, col) in row.withIndex()) {
      if (col == 0) {
        trailheads.add(Pos(rowIndex, colIndex))
      }
    }
  }
  var total = 0
  trailheads.forEach { total += getTrailheadScore(it, input) }
  return total
}

private fun getTrailheadRating(trailhead: Pos, input: List<List<Int>>): Int {
  val queue = mutableListOf<List<Pos>>()
  queue.add(listOf(trailhead))
  val paths = mutableSetOf<Set<Pos>>()
  while (queue.isNotEmpty()) {
    val path = queue.removeFirst()
    val item = path.last()
    val itemValue = input.getIntAt(item)
    if (itemValue == 9) {
      paths.add(path.toSet())
      continue
    }
    val posToCheck =
        listOf(
            Pos(item.row - 1, item.col),
            Pos(item.row + 1, item.col),
            Pos(item.row, item.col - 1),
            Pos(item.row, item.col + 1),
        )
    posToCheck.forEach { pos ->
      if (pos.row in input.indices && pos.col in input[0].indices) {
        val posValue = input.getIntAt(pos)
        if (itemValue + 1 == posValue) {
          queue.add(path + listOf(pos))
        }
      }
    }
  }
  return paths.size
}

private fun partTwo(input: List<List<Int>>): Int {
  val trailheads = mutableSetOf<Pos>()
  for ((rowIndex, row) in input.withIndex()) {
    for ((colIndex, col) in row.withIndex()) {
      if (col == 0) {
        trailheads.add(Pos(rowIndex, colIndex))
      }
    }
  }
  var total = 0
  trailheads.forEach { total += getTrailheadRating(it, input) }
  return total
}

fun main() {
  val input = readFileAsList("10/input").filter { it.isNotEmpty() }
  val intMatrix = input.map { it.map(Char::digitToInt) }
  println("Part 1: ${partOne(intMatrix)}")
  println("Part 2: ${partTwo(intMatrix)}")
}
