import Utils.readFileAsList

private fun partLine(line: String): Pair<String, List<Int>> {
  val splitA = line.split(" ")
  assert(splitA.size == 2)
  return Pair(splitA[0], splitA[1].split(",").map(String::toInt))
}

private fun printDepth(depth: Int, message: Any?) {
  println("${" ".repeat(depth * 4)} $message")
}

private fun buildArrangements(line: String, counts: List<Int>): Set<String> {
//  println("PROCESSING $line $counts")
  if (counts.isEmpty()) {
    return if (line.contains("#")) emptySet() else setOf(line)
  }
  if (line.isEmpty()) {
    return emptySet()
  }
  val firstSize = counts.first()
  val allArrangements = mutableSetOf<String>()
  for (index in 0..line.length - firstSize) {
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
        val suffixes = buildArrangements(suffix, counts.drop(1))
        allArrangements.addAll(suffixes.map { prefix + it })
      }
    }
    if (line[index] == '#') {
      break
    }
  }
//  println("$firstSize $allArrangements")
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

private fun partOne(input: List<String>): Int {
  val results =
      input.map { line ->
        val partedLine = partLine(line)
//        println("LINE ${partedLine.first} ${partedLine.second}")
        val result = buildArrangements(partedLine.first, partedLine.second)
//        println("${result}")
        return@map result.size
      }
  return results.reduce { acc, i -> acc + i }
}

private fun partTwo(input: List<String>) {
  TODO("Not yet implemented")
}

fun main() {
  val input = readFileAsList("12/input").map(String::trim).filter(String::isNotEmpty)
  //  println("Part 1: ${partOne(listOf(input[4]))}")
  println("Part 1: ${partOne(input)}")
  //    println("Part 2: ${partTwo(input)}")
}
