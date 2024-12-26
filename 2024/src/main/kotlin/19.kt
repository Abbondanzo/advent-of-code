import Utils.readFileAsList

private fun getPossibleCombinations(options: List<String>, display: String, memory: MutableMap<String, Long>): Long {
  return memory.getOrPut(display) {
    options.fold(0L) { count, option ->
      when {
        display == option -> count + 1
        display.startsWith(option) -> count + getPossibleCombinations(options, display.removePrefix(option), memory)
        else -> count
      }
    }
  }
}

private fun partOne(options: List<String>, displays: List<String>): Int {
  var total = 0
  val memory = mutableMapOf<String, Long>()
  for (display in displays) {
    val combos = getPossibleCombinations(options, display, memory)
    if (combos > 0) {
      total++
    }
  }
  return total
}

private fun partTwo(options: List<String>, displays: List<String>): Long {
  var total = 0L
  val memory = mutableMapOf<String, Long>()
  for (display in displays) {
    total += getPossibleCombinations(options, display, memory)
  }
  return total
}

fun main() {
  val input = readFileAsList("19/input")
  val options = input[0].split(",").map(String::trim).sortedBy { it.length }
  val displays = input.subList(2, input.size).filter(String::isNotEmpty)
  println("Part 1: ${partOne(options, displays)}")
  println("Part 2: ${partTwo(options, displays)}")
}
