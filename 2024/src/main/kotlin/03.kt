import Utils.readFileAsList

private val regex = Regex("mul\\((\\d+,\\d+)\\)")

private fun partOne(lines: List<String>): Int {
  var total = 0
  for (line in lines) {
    val matches = regex.findAll(line)
    for (match in matches) {
      val rawNumbers = match.groupValues[1].split(",").map(String::toInt)
      total += rawNumbers[0] * rawNumbers[1]
    }
  }
  return total
}

private val regexTwo = Regex("mul\\((\\d+,\\d+)\\)|don't\\(\\)|do\\(\\)")

private fun partTwo(lines: List<String>): Int {
  var total = 0
  var enabled = true
  for (line in lines) {
    val matches = regexTwo.findAll(line)
    for (match in matches) {
      when (match.groupValues[0]) {
        "don't()" -> enabled = false
        "do()" -> enabled = true
        else -> {
          if (enabled) {
            val rawNumbers = match.groupValues[1].split(",").map(String::toInt)
            total += rawNumbers[0] * rawNumbers[1]
          }
        }
      }
    }
  }
  return total
}

fun main() {
  val input = readFileAsList("03/input").filter { it.isNotEmpty() }
  println("Part 1: ${partOne(input)}")
  println("Part 2: ${partTwo(input)}")
}
