import Utils.readFileAsList

private fun parseToPattern(input: List<String>): List<List<String>> {
  val patterns = mutableListOf<List<String>>()
  var start = 0
  for (index in input.indices) {
    if (input[index].isEmpty()) {
      patterns.add(input.subList(start, index))
      start = index + 1
    }
  }
  if (start < input.size) {
    patterns.add(input.subList(start, input.size))
  }
  return patterns
}

private fun getReflectionSumWithSmudges(pattern: List<String>, smudges: Int): Int {
  fun isMirroredColumn(colIndex: Int): Boolean {
    var mismatchCount = 0
    for (offset in 0..colIndex) {
      val i = colIndex - offset
      val j = colIndex + 1 + offset
      if (j >= pattern[0].length) {
        break
      }
      mismatchCount += pattern.count { line -> line[i] != line[j] }
      if (mismatchCount > smudges) {
        return false
      }
    }
    return mismatchCount == smudges
  }
  fun isMirroredRow(rowIndex: Int): Boolean {
    var mismatchCount = 0
    for (offset in 0..rowIndex) {
      val i = rowIndex - offset
      val j = rowIndex + 1 + offset
      if (j >= pattern.size) {
        break
      }
      mismatchCount += pattern[i].withIndex().count { (index, char) -> char != pattern[j][index] }
      if (mismatchCount > smudges) {
        return false
      }
    }
    return mismatchCount == smudges
  }

  for (colIndex in 0 ..< pattern[0].length - 1) {
    if (isMirroredColumn(colIndex)) {
      return colIndex + 1
    }
  }
  for (rowIndex in 0 ..< pattern.size - 1) {
    if (isMirroredRow(rowIndex)) {
      return (rowIndex + 1) * 100
    }
  }

  return 0
}

private fun partOne(input: List<List<String>>): Int {
  return input
      .map { pattern -> getReflectionSumWithSmudges(pattern, 0) }
      .reduce { acc, i -> acc + i }
}

private fun partTwo(input: List<List<String>>): Int {
  return input
      .map { pattern -> getReflectionSumWithSmudges(pattern, 1) }
      .reduce { acc, i -> acc + i }
}

fun main() {
  val input = readFileAsList("13/input").map(String::trim)
  val patterns = parseToPattern(input)
  println("Part 1: ${partOne(patterns)}")
  println("Part 2: ${partTwo(patterns)}")
}
