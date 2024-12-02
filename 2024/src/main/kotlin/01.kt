import Utils.readFileAsList
import kotlin.math.absoluteValue

private fun partOne(lines: List<String>): Int {
  val left = mutableListOf<Int>()
  val right = mutableListOf<Int>()
  for (line in lines) {
    val splits = line.split(" ")
    left.add(splits.first().toInt())
    right.add(splits.last().toInt())
  }
  left.sort()
  right.sort()
  var total = 0
  for (i in left.indices) {
    total += (left[i] - right[i]).absoluteValue
  }
  return total
}

private fun partTwo(lines: List<String>): Int {
  val leftGroups = lines.map { it.split(" ").first().toInt() }
  val rightGroups = lines.map { it.split(" ").last().toInt() }.groupBy { it }
  var total = 0
  for (left in leftGroups) {
    total += left * (rightGroups[left]?.size ?: 0)
  }
  return total
}

fun main() {
  val input = readFileAsList("01/input").filter { it.isNotEmpty() }
  println("Part 1: ${partOne(input)}")
  println("Part 2: ${partTwo(input)}")
}
