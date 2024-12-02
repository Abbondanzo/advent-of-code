import Utils.readFileAsList
import kotlin.math.absoluteValue

private fun safeRow(items: List<Int>): Boolean {
  assert(items.size >= 2)
  val decreasing = items[0] > items[1]
  var idx = 1
  var prevNum = items[0]
  while (idx < items.size) {
    val curNum = items[idx]
    if (curNum > prevNum && decreasing) {
      return false
    }
    if (curNum < prevNum && !decreasing) {
      return false
    }
    val diff = (curNum - prevNum).absoluteValue
    if (diff !in 1..3) {
      return false
    }
    prevNum = curNum
    idx++
  }
  return true
}

private fun partOne(lines: List<String>): Int {
  var safeReports = 0
  for (line in lines) {
    val items = line.split(" ").map(String::toInt)
    if (safeRow(items)) {
      safeReports++
    }
  }
  return safeReports
}

private fun safeRowV2(items: List<Int>): Boolean {
  assert(items.size >= 2)
  val isBasicSafe = safeRow(items)
  if (isBasicSafe) {
    return true
  }
  // Rebuilding the list every time == bad, but it's fast enough that it works
  for (i in items.indices) {
    val newList = items.subList(0, i) + items.subList(i + 1, items.size)
    if (safeRow(newList)) {
      return true
    }
  }
  return false
}

private fun partTwo(lines: List<String>): Int {
  var safeReports = 0
  for (line in lines) {
    val items = line.split(" ").map(String::toInt)
    if (safeRowV2(items)) {
      safeReports++
    }
  }
  return safeReports
}

fun main() {
  val input = readFileAsList("02/input").filter { it.isNotEmpty() }
  println("Part 1: ${partOne(input)}")
  println("Part 2: ${partTwo(input)}")
}
