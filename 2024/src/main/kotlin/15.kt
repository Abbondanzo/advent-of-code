import Utils.readFileAsList
import Utils.Pos
import Utils.Direction

private const val DEBUG: Boolean = false

private data class Warehouse(
  val robotSpot: Pos,
  val walls: Set<Pos>,
  val boxes: Set<Pos>,
)

private fun parseWarehouse(lines: List<String>): Pair<Warehouse, List<Direction>> {
  var readingMoves = false
  val walls = mutableSetOf<Pos>()
  val boxes = mutableSetOf<Pos>()
  val directions = mutableListOf<Direction>()
  var maybeInitialSpot: Pos? = null
  for ((rowIndex, line) in lines.withIndex()) {
    if (!readingMoves) {
      if (line.isEmpty()) {
        readingMoves = true
      } else {
        for ((colIndex, char) in line.withIndex()) {
          when (char) {
            '#' -> walls.add(Pos(rowIndex, colIndex))
            'O' -> boxes.add(Pos(rowIndex, colIndex))
            '@' -> maybeInitialSpot = Pos(rowIndex, colIndex)
          }
        }
      }
    } else {
      for (dir in line) {
        val direction = when (dir) {
          '<' -> Direction.LEFT
          '>' -> Direction.RIGHT
          '^' -> Direction.UP
          'v' -> Direction.DOWN
          else -> error("Unrecognized direction $dir")
        }
        directions.add(direction)
      }
    }
  }
  val initialSpot = maybeInitialSpot ?: error("Initial spot not found")
  return Warehouse(initialSpot, walls = walls, boxes = boxes) to directions
}

private fun printWarehouse(warehouse: Warehouse) {
  val maxRow = warehouse.walls.maxOf { it.row }
  val maxCol = warehouse.walls.maxOf { it.col }
  for (row in 0..maxRow) {
    val rowSb = StringBuilder()
    for (col in 0..maxCol) {
      val pos = Pos(row, col)
      when {
        warehouse.robotSpot == pos -> rowSb.append('@')
        warehouse.boxes.contains(pos) -> rowSb.append('O')
        warehouse.walls.contains(pos) -> rowSb.append('#')
        else -> rowSb.append('.')
      }
    }
    println(rowSb.toString())
  }
}

private fun partOne(warehouse: Warehouse, directions: List<Direction>): Int {
  var currentSpot = warehouse.robotSpot
  val movedBoxes = mutableSetOf<Pos>()
  movedBoxes.addAll(warehouse.boxes)
  for (direction in directions) {
    if (DEBUG) {
      println("Move $direction:")
      printWarehouse(Warehouse(currentSpot, warehouse.walls, movedBoxes))
    }
    val nextSpot = direction.applyOffset(currentSpot)
    // You've hit a wall, don't do anything
    if (warehouse.walls.contains(nextSpot)) {
      continue
    }
    // There are no boxes in the way, move
    if (!movedBoxes.contains(nextSpot)) {
      currentSpot = nextSpot
      continue
    }
    // There are boxes we need to move
    var canMove = true
    var nextBoxSpot = direction.applyOffset(nextSpot)
    while (true) {
      if (warehouse.walls.contains(nextBoxSpot)) {
        canMove = false
        break
      }
      if (!movedBoxes.contains(nextBoxSpot)) {
        break
      }
      nextBoxSpot = direction.applyOffset(nextBoxSpot)
    }
    if (canMove) {
      movedBoxes.remove(nextSpot)
      movedBoxes.add(nextBoxSpot)
      currentSpot = nextSpot
    }
  }
  var total = 0
  for (box in movedBoxes) {
    total += (100 * box.row) + box.col
  }
  return total
}

private fun printWideWarehouse(walls: Set<Pos>, boxes: Set<WideBox>, robot: Pos) {
  val maxRow = walls.maxOf { it.row }
  val maxCol = walls.maxOf { it.col }
  for (row in 0..maxRow) {
    val rowSb = StringBuilder()
    var nextChar: Char? = null
    for (col in 0..maxCol) {
      val pos = Pos(row, col)
      when {
        boxes.any { it.pos == pos } -> {
          rowSb.append("[")
          nextChar = ']'
        }

        pos == robot -> {
          rowSb.append("@")
        }

        walls.contains(pos) -> {
          rowSb.append('#')
        }

        else -> {
          if (nextChar != null) {
            rowSb.append(nextChar)
            nextChar = null
          } else {
            rowSb.append('.')
          }
        }
      }
    }
    println(rowSb.toString())
  }
}

private data class WideBox(val pos: Pos) {
  fun applyDirection(direction: Direction): WideBox {
    return WideBox(direction.applyOffset(pos))
  }

//  fun overlaps(walls: Set<Pos>): Boolean {
//    return walls.contains(pos) || walls.contains(pos + Pos(1, 0))
//  }

  fun overlapsPos(pos: Pos): Boolean {
    return this.pos == pos || this.pos + Pos(0, 1) == pos
  }

  fun overlapsWalls(walls: Set<Pos>): Boolean {
    return walls.contains(pos) || walls.contains(pos + Pos(0, 1))
  }

  fun overlaps(other: WideBox): Boolean {
    return this == other || other.pos + Pos(0, -1) == pos || other.pos + Pos(0, 1) == pos
  }

  fun overlaps(boxes: Set<WideBox>): Boolean {
    val left = WideBox(pos + Pos(0, -1))
    return boxes.contains(this) || boxes.contains(left)
  }
}

private fun partTwo(warehouse: Warehouse, directions: List<Direction>): Int {
  val newWalls = warehouse.walls.flatMap { listOf(Pos(it.row, it.col * 2), Pos(it.row, it.col * 2 + 1)) }.toSet()
  // Only use left-most for boxes
  val newBoxes = warehouse.boxes.map { WideBox(Pos(it.row, it.col * 2)) }.toMutableSet()
  val boxCount = newBoxes.size
  var currentSpot = Pos(warehouse.robotSpot.row, warehouse.robotSpot.col * 2)
  for (direction in directions) {
    if (DEBUG) {
      printWideWarehouse(newWalls, newBoxes, currentSpot)
      println("")
      println("Move $direction:")
    }
    val nextSpot = direction.applyOffset(currentSpot)
    // You've hit a wall, don't do anything
    if (newWalls.contains(nextSpot)) {
      continue
    }
    // There are no boxes in the way, move
    if (!newBoxes.any { it.overlapsPos(nextSpot) }) {
      currentSpot = nextSpot
      continue
    }
    // There are boxes we need to move
    var canMove = true
    val boxesToMove = mutableSetOf<WideBox>()
    val nextBoxQueue = mutableListOf<WideBox>()
    nextBoxQueue.addAll(newBoxes.filter { it.overlapsPos(nextSpot) })
    while (nextBoxQueue.isNotEmpty()) {
      val boxToProcess = nextBoxQueue.removeFirst()
      val boxToProcessNextSpot = boxToProcess.applyDirection(direction)
      if (boxToProcessNextSpot.overlapsWalls(newWalls)) {
        canMove = false
        break
      }
      boxesToMove.add(boxToProcess)
      val nextBoxes =
        newBoxes.filter { !boxesToMove.contains(it) && !nextBoxQueue.contains(it) && it.overlaps(boxToProcessNextSpot) }
      nextBoxQueue.addAll(nextBoxes)
    }
    if (canMove) {
      newBoxes.removeAll(boxesToMove)
      newBoxes.addAll(boxesToMove.map { it.applyDirection(direction) })
      if (newBoxes.size != boxCount) {
        error("Missing a box!")
      }
      currentSpot = nextSpot
    }
  }
  if (DEBUG) {
    printWideWarehouse(newWalls, newBoxes, currentSpot)
  }

  var total = 0
  for (box in newBoxes) {
    total += 100 * box.pos.row
    total += box.pos.col
  }
  return total
}

fun main() {
  val input = readFileAsList("15/input")
  val (warehouse, directions) = parseWarehouse(input)
  println("Part 1: ${partOne(warehouse, directions)}")
  println("Part 2: ${partTwo(warehouse, directions)}")
}
