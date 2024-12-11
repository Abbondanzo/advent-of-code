import Utils.readFileAsList

/**
 * Starting from the coordinates of a valid 'X', crawl in the provided direction to find "XMAS" in
 * order.
 */
private fun getXmasFromX(
    row: Int,
    col: Int,
    rowDelta: Int,
    colDelta: Int,
    input: List<List<Char>>
): Boolean {
  assert(input[row][col] == 'X')
  for ((index, char) in "XMAS".withIndex()) {
    val rowOffset = row + (rowDelta * index)
    if (rowOffset !in input.indices) {
      return false
    }
    val inputRow = input[rowOffset]
    val colOffset = col + (colDelta * index)
    if (colOffset !in inputRow.indices) {
      return false
    }
    if (inputRow[colOffset] != char) {
      return false
    }
  }
  return true
}

private fun partOne(input: List<List<Char>>): Int {
  var total = 0
  for (row in input.indices) {
    val matrixRow = input[row]
    for (col in matrixRow.indices) {
      if (matrixRow[col] == 'X') {
        val successes =
            listOf(
                // Left
                getXmasFromX(row, col, 0, -1, input),
                // Right
                getXmasFromX(row, col, 0, 1, input),
                // Up
                getXmasFromX(row, col, -1, 0, input),
                // Down
                getXmasFromX(row, col, 1, 0, input),
                // Diagonal up-left
                getXmasFromX(row, col, -1, -1, input),
                // Diagonal up-right
                getXmasFromX(row, col, -1, 1, input),
                // Diagonal down-left
                getXmasFromX(row, col, 1, -1, input),
                // Diagonal down-right
                getXmasFromX(row, col, 1, 1, input),
            )
        total += successes.count { it }
      }
    }
  }
  return total
}

/**
 * Starting from the coordinates of a valid 'A', check the four corners as alternating pairs. Two
 * opposite corners must be either M or S, they cannot be the same.
 */
private fun getMasFromA(row: Int, col: Int, input: List<List<Char>>): Boolean {
  assert(input[row][col] == 'A')
  if (row == 0 || row == input.size - 1) {
    return false
  }
  if (col == 0 || col == input[0].size - 1) {
    return false
  }
  // Top-left to bottom-right
  val topLeft = input[row - 1][col - 1]
  val bottomRight = input[row + 1][col + 1]
  val isValidMas = topLeft != bottomRight && topLeft in "MS" && bottomRight in "MS"
  if (!isValidMas) {
    return false
  }
  val topRight = input[row - 1][col + 1]
  val bottomLeft = input[row + 1][col - 1]
  return topRight != bottomLeft && topRight in "MS" && bottomLeft in "MS"
}

private fun partTwo(input: List<List<Char>>): Int {
  var total = 0
  for (row in input.indices) {
    val inputRow = input[row]
    for (col in inputRow.indices) {
      if (inputRow[col] == 'A' && getMasFromA(row, col, input)) {
        total++
      }
    }
  }
  return total
}

fun main() {
  val input = readFileAsList("04/input").filter { it.isNotEmpty() }
  val matrix = input.map { it.toCharArray().toList() }
  println("Part 1: ${partOne(matrix)}")
  println("Part 2: ${partTwo(matrix)}")
}
