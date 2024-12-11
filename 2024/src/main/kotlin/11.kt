import Utils.readFileAsList

private fun getNextNumbers(num: Long): List<Long> {
  return when {
    num == 0L -> listOf(1L)
    num.toString().length % 2 == 0 ->
        listOf(
            num.toString().take(num.toString().length / 2).toLong(),
            num.toString().takeLast(num.toString().length / 2).toLong(),
        )
    else -> listOf(num * 2024)
  }
}

private fun partOne(input: List<Long>): Int {
  var stones = mutableListOf<Long>()
  stones.addAll(input)
  var iterations = 0
  while (iterations < 25) {
    val newStones = mutableListOf<Long>()
    for (stone in stones) {
      newStones.addAll(getNextNumbers(stone))
    }
    println("$iterations")
    stones = newStones
    iterations++
  }
  return stones.size
}

private data class BlinkKey(
    val value: Long,
    val remainingBlinks: Int,
)

private fun recursiveCacheSeed(
    stone: Long,
    remainingBlinks: Int,
    cache: MutableMap<BlinkKey, Long>
): Long {
  return cache.getOrPut(BlinkKey(stone, remainingBlinks)) {
    when {
      remainingBlinks < 0 -> error("Should not happen")
      remainingBlinks == 0 -> 1L
      else ->
          getNextNumbers(stone)
              .map { recursiveCacheSeed(it, remainingBlinks - 1, cache) }
              .reduce { acc, l -> acc + l }
    }
  }
}

private fun partTwo(input: List<Long>): Long {
  val blinkCache = mutableMapOf<BlinkKey, Long>()
  var total = 0L
  for (stone in input) {
    total += recursiveCacheSeed(stone, 75, blinkCache)
  }
  return total
}

fun main() {
  val input = readFileAsList("11/input").filter { it.isNotEmpty() }
  val stones = input[0].split(" ").map(String::toLong)
  println("Part 1: ${partOne(stones)}")
  println("Part 2: ${partTwo(stones)}")
}
