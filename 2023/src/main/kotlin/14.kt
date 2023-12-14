import Utils.readFileAsList

private const val ROUND = 'O'
private const val CUBE = '#'
private const val EMPTY = '.'

private fun partOne(input: List<String>): Int {
  val loads =
      input[0].indices.map { colIndex ->
        var load = 0
        var top = 0
        var rockCount = 0
        for (rowIndex in input.indices) {
          when (input[rowIndex][colIndex]) {
            ROUND -> {
              rockCount++
            }
            CUBE -> {
              while (rockCount > 0) {
                load += input.size - top
                top++
                rockCount--
              }
              top = rowIndex + 1
            }
          }
        }
        while (rockCount > 0) {
          load += input.size - top
          top++
          rockCount--
        }
        return@map load
      }

  return loads.reduce { acc, i -> acc + i }
}

// It's gross, it could be simplified, but it works
private fun runCycle(input: MutableList<MutableList<Char>>) {
  // North
  input[0].indices.forEach { colIndex ->
    var top = 0
    var rockCount = 0
    for (rowIndex in input.indices) {
      when (input[rowIndex][colIndex]) {
        ROUND -> {
          rockCount++
        }
        CUBE -> {
          while (top < rowIndex) {
            input[top][colIndex] = if (rockCount > 0) ROUND else EMPTY
            top++
            rockCount--
          }
          rockCount = 0
          top = rowIndex + 1
        }
      }
    }
    while (top < input.size) {
      input[top][colIndex] = if (rockCount > 0) ROUND else EMPTY
      top++
      rockCount--
    }
  }
  // West
  input.indices.forEach { rowIndex ->
    var left = 0
    var rockCount = 0
    for (colIndex in input[rowIndex].indices) {
      when (input[rowIndex][colIndex]) {
        ROUND -> {
          rockCount++
        }
        CUBE -> {
          while (left < colIndex) {
            input[rowIndex][left] = if (rockCount > 0) ROUND else EMPTY
            left++
            rockCount--
          }
          rockCount = 0
          left = colIndex + 1
        }
      }
    }
    while (left < input[0].size) {
      input[rowIndex][left] = if (rockCount > 0) ROUND else EMPTY
      left++
      rockCount--
    }
  }
  // South
  input[0].indices.forEach { colIndex ->
    var bottom = input.size - 1
    var rockCount = 0
    for (rowIndex in input.indices.reversed()) {
      when (input[rowIndex][colIndex]) {
        ROUND -> {
          rockCount++
        }
        CUBE -> {
          while (bottom > rowIndex) {
            input[bottom][colIndex] = if (rockCount > 0) ROUND else EMPTY
            bottom--
            rockCount--
          }
          rockCount = 0
          bottom = rowIndex - 1
        }
      }
    }
    while (bottom >= 0) {
      input[bottom][colIndex] = if (rockCount > 0) ROUND else EMPTY
      bottom--
      rockCount--
    }
  }
  // East
  input.indices.forEach { rowIndex ->
    var right = input[rowIndex].size - 1
    var rockCount = 0
    for (colIndex in input[rowIndex].indices.reversed()) {
      when (input[rowIndex][colIndex]) {
        ROUND -> {
          rockCount++
        }
        CUBE -> {
          while (right > colIndex) {
            input[rowIndex][right] = if (rockCount > 0) ROUND else EMPTY
            right--
            rockCount--
          }
          rockCount = 0
          right = colIndex - 1
        }
      }
    }
    while (right >= 0) {
      input[rowIndex][right] = if (rockCount > 0) ROUND else EMPTY
      right--
      rockCount--
    }
  }
}

private fun partTwo(input: List<String>): Int {
  val cache = mutableMapOf<String, Int>()
  val mutable = input.map { it.toMutableList() }.toMutableList()

  var steps = 0
  while (steps < 1000000000) {
    runCycle(mutable)
    steps++
    val key = mutable.toString()
    if (cache.containsKey(key)) {
      val cyclesToRepeat = steps - cache[key]!!
      // Integers floor in division
      val remaining = ((1000000000 - steps) / cyclesToRepeat) * cyclesToRepeat
      steps += remaining
    } else {
      cache[key] = steps
    }
  }

  var load = 0
  for (rowIndex in mutable.indices) {
    for (colIndex in mutable[0].indices) {
      if (mutable[rowIndex][colIndex] == ROUND) {
        load += mutable.size - rowIndex
      }
    }
  }

  return load
}

fun main() {
  val input = readFileAsList("14/input").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${partOne(input)}")
  println("Part 2: ${partTwo(input)}")
}
