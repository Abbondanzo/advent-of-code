import Utils.readFileAsList

private fun partLine(line: String): Pair<String, List<Int>> {
  val splitA = line.split(" ")
  assert(splitA.size == 2)
  return Pair(splitA[0], splitA[1].split(",").map(String::toInt))
}

private fun getArrangementCount(
    conditions: String,
    groupCounts: List<Int>,
    cache: MutableMap<String, Long> = mutableMapOf(),
): Long {
  if (conditions.isEmpty()) {
    return if (groupCounts.isEmpty()) 1 else 0
  }
  if (groupCounts.isEmpty()) {
    return if (conditions.contains('#')) 0 else 1
  }
  val cacheKey = "$conditions $groupCounts"
  if (cache.containsKey(cacheKey)) {
    return cache[cacheKey]!!
  }
  var arrangements = 0L
  if (conditions[0] in ".?") {
    arrangements += getArrangementCount(conditions.substring(1), groupCounts, cache)
  }
  val groupSize = groupCounts.first()
  if (conditions[0] in "#?") {
    if (groupSize <= conditions.length &&
        !conditions.subSequence(0 ..< groupSize).contains(".") &&
        (groupSize == conditions.length || conditions[groupSize] != '#')) {
      val remainder =
          if (groupSize == conditions.length) "" else conditions.substring(groupSize + 1)
      arrangements += getArrangementCount(remainder, groupCounts.drop(1), cache)
    }
  }
  cache[cacheKey] = arrangements
  return arrangements
}

private fun partOne(input: List<String>): Long {
  val results =
      input.map { line ->
        val partedLine = partLine(line)
        val result = getArrangementCount(partedLine.first, partedLine.second)
        return@map result
      }
  return results.reduce { acc, i -> acc + i }
}

private fun partTwo(input: List<String>): Long {
  val results =
      input.map { line ->
        val partedLine = partLine(line)
        val repeatedLine = (1..5).joinToString("?") { partedLine.first }
        val repeatedCounts = (1..5).flatMap { partedLine.second }
        val result = getArrangementCount(repeatedLine, repeatedCounts)
        return@map result
      }
  return results.reduce { acc, i -> acc + i }
}

fun main() {
  val input = readFileAsList("12/input").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${partOne(input)}")
  println("Part 2: ${partTwo(input)}")
}
