import Utils.readFileAsList

private fun isValidEquation(total: Long, items: List<Long>): Boolean {
  if (items.size < 2 || total < 0) {
    return false
  }
  if (items.size == 2) {
    return total == items[0] + items[1] || total == items[0] * items[1]
  }
  return isValidEquation(total - items.last(), items.dropLast(1))
      || (total % items.last() == 0L && isValidEquation(total / items.last(), items.dropLast(1)))
}

private fun partOne(equations: List<Pair<Long, List<Long>>>): Long {
  var total = 0L
  for (equation in equations) {
    if (isValidEquation(equation.first, equation.second)) {
      total += equation.first
    }
  }
  return total
}

private fun isValidEquationPartTwo(total: Long, items: List<Long>): Boolean {
  if (items.size < 2 || total < 0) {
    return false
  }
  if (items.size == 2) {
    return total == items[0] + items[1] || total == items[0] * items[1] || total == "${items[0]}${items[1]}".toLong()
  }
  return isValidEquationPartTwo(total - items.last(), items.dropLast(1))
      || (total % items.last() == 0L && isValidEquationPartTwo(total / items.last(), items.dropLast(1)))
      || (total.toString().endsWith(items.last().toString()) && isValidEquationPartTwo(total.toString().removeSuffix(items.last().toString()).toLong(), items.dropLast(1)))

}

private fun partTwo(equations: List<Pair<Long, List<Long>>>): Long {
  var total = 0L
  for (equation in equations) {
    if (isValidEquationPartTwo(equation.first, equation.second)) {
      total += equation.first
    }
  }
  return total
}

private fun parseRawInput(input: List<String>): List<Pair<Long, List<Long>>> {
  return input.map { line ->
    val split = line.split(":")
    split[0].toLong() to split[1].trim().split(" ").map(String::toLong)
  }
}

fun main() {
  val input = readFileAsList("07/input").filter { it.isNotEmpty() }
  val items = parseRawInput(input)
  println("Part 1: ${partOne(items)}")
  println("Part 2: ${partTwo(items)}")
}
