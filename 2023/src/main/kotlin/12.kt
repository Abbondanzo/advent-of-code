import Utils.readFileAsList

private fun partLine(line: String): Pair<String, List<Int>> {
  val splitA = line.split(" ")
  assert(splitA.size == 2)
  return Pair(splitA[0], splitA[1].split(",").map(String::toInt))
}

private fun getArrangementCount(conditions: String, groupCounts: List<Int>, cache: MutableMap<String, Long> = mutableMapOf()): Long {
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
    if (groupSize <= conditions.length
      && !conditions.subSequence(0..<groupSize).contains(".")
      && (groupSize == conditions.length || conditions[groupSize] != '#')) {
      val remainder = if (groupSize == conditions.length) "" else conditions.substring(groupSize + 1)
      arrangements += getArrangementCount(remainder, groupCounts.drop(1), cache)
    }
  }
  cache[cacheKey] = arrangements
//  val char = conditions[0]
//
//
//
//  val remainingGroups = conditions.map(String::length).reduce { acc, i -> acc + i }
//  val remainingCounts = groupCounts.reduce { acc, i -> acc + i }
//  if (remainingGroups < remainingCounts) {
//    return 0
//  }
//  val firstSize = groupCounts.first()
//  val firstGroup = conditions.first()
//  if (firstGroup.length < firstSize) {
//    return getArrangementCount(conditions.drop(1), groupCounts)
//  }
//  var arrangements = 0
//  for (index in 0..firstGroup.length - firstSize) {
//    val legalLeft = index == 0 || firstGroup[index - 1] != '#'
//    val atEnd = index + firstSize >= firstGroup.length
//    val legalRight = atEnd || firstGroup[index + firstSize] != '#'
//    if (legalLeft && legalRight) {
//      val nextArrangementCount = if (atEnd) {
//        getArrangementCount(conditions.drop(1), groupCounts.drop(1))
//      } else {
//        val suffix = firstGroup.substring(index + firstSize + 1)
//        getArrangementCount(listOf(suffix) + conditions.drop(1), groupCounts.drop(1))
//      }
//      arrangements += nextArrangementCount
//    }
//  }
  return arrangements
}

private fun printDepth(depth: Int, message: Any?) {
  println("${" ".repeat(depth * 4)} $message")
}

private fun buildArrangements(line: String, counts: List<Int>, cache: MutableMap<String, Set<String>> = mutableMapOf()): Set<String> {
  if (counts.isEmpty()) {
    return if (line.contains("#")) emptySet() else setOf(line)
  }
  if (line.isEmpty()) {
    return emptySet()
  }
  val firstSize = counts.first()
  val cacheKey = "$line $firstSize"
  if (cache.containsKey(cacheKey)) {
    return cache[cacheKey]!!
  }
  val allArrangements = mutableSetOf<String>()
  val maxLeft =
      if (counts.size == 1) {
        line.length - firstSize
      } else {
        line.length - counts.drop(1).reduce { acc, i -> acc + i + 1 } - firstSize
      }
  for (index in 0..maxLeft) {
    val legalLeft = index == 0 || line[index - 1] != '#'
    val atEnd = index + firstSize >= line.length
    val legalRight = atEnd || line[index + firstSize] != '#'
    if (legalLeft && legalRight && !line.substring(index ..< index + firstSize).contains('.')) {
      val nextLine = line.replaceRange(index, index + firstSize, "#".repeat(firstSize))
      if (atEnd) {
        if (counts.size == 1) allArrangements.add(nextLine)
      } else {
        val prefix = nextLine.substring(0, index + firstSize + 1)

        val suffix = nextLine.substring(index + firstSize + 1)
        //        println("BUILDING ARRANGEMENTS $firstSize $prefix $suffix $line $index")
        val suffixes = buildArrangements(suffix, counts.drop(1), cache)
        allArrangements.addAll(suffixes.map { prefix + it })
      }
    }
    if (line[index] == '#') {
      break
    }
  }
  //  println("$firstSize $allArrangements")
  cache[cacheKey] = allArrangements
  return allArrangements
}

private fun parseLine(line: String, counts: List<Int>, depth: Int = 1): Int {
  if (counts.isEmpty()) {
    return if (line.contains("#")) 0 else 1
  }
  val groups = line.split(".").filter(String::isNotEmpty)
  if (groups.isEmpty()) {
    return 0
  }

  val firstSize = counts.first()
  val firstGroup = groups.first()

  if (firstGroup.length < firstSize) {
    return parseLine(groups.drop(1).joinToString("."), counts, depth + 1)
  }

  var arrangements = 0
  for (index in 0..firstGroup.length - firstSize) {
    val legalLeft = index == 0 || firstGroup[index - 1] == '?'
    val atEnd = index + firstSize >= firstGroup.length
    val legalRight = atEnd || firstGroup[index + firstSize] == '?'
    if (legalLeft && legalRight) {
      val remainder = if (atEnd) "" else firstGroup.substring(index + firstSize + 1)
      val rawLine = listOf(remainder) + groups.drop(1)
      val count = parseLine(rawLine.joinToString("."), counts.drop(1), depth + 1)
      arrangements += count
    }
  }
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
      input.withIndex().map { (index, line) ->
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
