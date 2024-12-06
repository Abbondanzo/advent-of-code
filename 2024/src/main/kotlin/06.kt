import Utils.readFileAsList

data class Pos(val row: Int, val col: Int)

private fun getStartingPosition(lines: List<String>): Pos {
  for ((rowIdx, row) in lines.withIndex()) {
    for (col in row.indices) {
      if (row[col] == '^') {
        return Pos(rowIdx, col)
      }
    }
  }
  error("Could not find start")
}

enum class Direction {
  UP,
  DOWN,
  LEFT,
  RIGHT;

  fun rotateRight(): Direction {
    return when (this) {
      UP -> RIGHT
      RIGHT -> DOWN
      DOWN -> LEFT
      LEFT -> UP
    }
  }

  fun applyOffset(pos: Pos): Pos {
    return when (this) {
      UP -> Pos(pos.row - 1, pos.col)
      DOWN -> Pos(pos.row + 1, pos.col)
      LEFT -> Pos(pos.row, pos.col - 1)
      RIGHT -> Pos(pos.row, pos.col + 1)
    }
  }
}

private fun partOne(lines: List<String>): Int {
  var curPosition = getStartingPosition(lines)
  var direction = Direction.UP
  val visited = mutableSetOf<Pos>()
  while (true) {
    visited.add(curPosition)
    val nextPos = direction.applyOffset(curPosition)
    if (nextPos.row !in lines.indices) {
      break
    }
    if (nextPos.col !in 0..<lines[0].length) {
      break
    }

    if (lines[nextPos.row][nextPos.col] == '#') {
      direction = direction.rotateRight()
    } else {
      curPosition = nextPos
    }
  }


  return visited.size
}

private fun partTwo(lines: List<String>): Int {
  var curPosition = getStartingPosition(lines)
  var direction = Direction.UP
  val rotations = mutableSetOf<Pair<Pos, Direction>>()
  val newBlocks = mutableSetOf<Pos>()
  while (true) {
    val nextPos = direction.applyOffset(curPosition)
    if (nextPos.row !in lines.indices) {
      break
    }
    if (nextPos.col !in 0..<lines[0].length) {
      break
    }
//    if (rotations.any { (it.first.row == curPosition.row || it.first.col == curPosition.col) && it.second == rotateRight(direction) }) {
//      newBlocks.add(nextPos)
//    }
    if (lines[nextPos.row][nextPos.col] == '#') {
      rotations.add(curPosition to direction)
      direction = direction.rotateRight()
    } else {
      // Simulate block
      val rotate = direction.rotateRight()
      val hasRotation = rotations.filter { it.second == rotate }.any { (pos, _) ->
        when (rotate) {
          Direction.LEFT -> {
            pos.row == curPosition.row && pos.col <= curPosition.col
          }
          Direction.UP -> {
            pos.col == curPosition.col && pos.row <= curPosition.row
          }
          Direction.RIGHT -> {
            pos.row == curPosition.row && pos.col >= curPosition.col
          }
          Direction.DOWN -> {
            pos.col == curPosition.col && pos.row >= curPosition.row
          }
        }
      }
      if (hasRotation) {
        newBlocks.add(nextPos)
      }

      curPosition = nextPos
    }
  }
//  curPosition = getStartingPosition(lines)
//  direction = Pos(-1, 0)

//  while (true) {
//    val nextPos = Pos(curPosition.row + direction.row, curPosition.col + direction.col)
//    if (nextPos.row !in lines.indices) {
//      break
//    }
//    if (nextPos.col !in 0..<lines[0].length) {
//      break
//    }
//    if (lines[nextPos.row][nextPos.col] == '#') {
//      direction = rotateRight(direction)
//    } else {
//      if (rotations.any { (it.first.row == curPosition.row || it.first.col == curPosition.col) && it.second == rotateRight(direction) }) {
//        newBlocks.add(nextPos)
//      }
//      curPosition = nextPos
//    }
//  }
//  newBlocks.removeAll {
//    try {
//      lines[it.row][it.col] == '#'
//    } catch (_: Throwable) {
//      false
//    }
//  }
//  if (newBlocks.contains(getStartingPosition(lines))) {
//    error("Should not block starting position")
//  }
  println(newBlocks)
  return newBlocks.size
}

private fun partTwoBruteForceHelper(lines: List<String>, startingPosition: Pos, blockingPosition: Pos, startingDirection: Direction): Boolean {
  var curPosition = startingPosition
  var direction = startingDirection
  val visited = mutableSetOf<Pair<Pos, Direction>>()
  while (true) {
    if (visited.contains(curPosition to direction)) {
      return true
    }
    visited.add(curPosition to direction)
    val nextPos = direction.applyOffset(curPosition)
    if (nextPos.row !in lines.indices) {
      return false
    }
    if (nextPos.col !in 0..<lines[0].length) {
      return false
    }
    if (lines[nextPos.row][nextPos.col] == '#' || nextPos == blockingPosition) {
      direction = direction.rotateRight()
    } else {
      curPosition = nextPos
    }
  }
}

private fun partTwoBruteForce(lines: List<String>): Int {
  val startingPosition = getStartingPosition(lines)
  var totalBlockers = 0
  for (row in lines.indices) {
    for (col in lines[0].indices) {
      val char = lines[row][col]
      if (char == '.') {
        if (partTwoBruteForceHelper(lines, startingPosition, Pos(row, col), Direction.UP)) {
          totalBlockers++
        }
      }
    }
  }
  return totalBlockers
}

fun main() {
  val input = readFileAsList("06/input").filter { it.isNotEmpty() }
  println("Part 1: ${partOne(input)}")
  println("Part 2: ${partTwoBruteForce(input)}")
}
