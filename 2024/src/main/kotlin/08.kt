import Utils.readFileAsList
import Utils.Pos

private fun isWithinBounds(lines: List<String>, pos: Pos): Boolean {
  return pos.row in lines.indices && pos.col in lines[0].indices
}

private fun partOne(lines: List<String>): Int {
  val nodes = mutableMapOf<Char, MutableList<Pos>>()
  for ((rowIndex, row) in lines.withIndex()) {
    for ((colIndex, col) in row.withIndex()) {
      if (col != '.' && col.isLetterOrDigit()) {
        val nodeList = nodes.getOrPut(col) { mutableListOf() }
        nodeList.add(Pos(rowIndex, colIndex))
      }
    }
  }
  val antiNodes = mutableSetOf<Pos>()
  nodes.forEach { (_, antennaPos) ->
    if (antennaPos.size < 2) {
      return@forEach
    }
    antennaPos.forEach { ant ->
      antennaPos.forEach { otherAnt ->
        if (ant != otherAnt) {
          val rowDiff = otherAnt.row - ant.row
          val colDiff = otherAnt.col - ant.col
          antiNodes.add(Pos(otherAnt.row + rowDiff, otherAnt.col + colDiff))
          antiNodes.add(Pos(ant.row - rowDiff, ant.col - colDiff))
        }
      }
    }
  }
  antiNodes.removeAll { !isWithinBounds(lines, it) }
//  for ((rowIndex, line) in lines.withIndex()) {
//    println(line.mapIndexed { colIndex, char ->
//      if (char == '.' && antiNodes.contains(Pos(rowIndex, colIndex))) {
//        '#'
//      } else {
//        char
//      }
//    }.joinToString(""))
//  }
  return antiNodes.size
}

private fun partTwo(lines: List<String>): Int {
  val nodes = mutableMapOf<Char, MutableList<Pos>>()
  for ((rowIndex, row) in lines.withIndex()) {
    for ((colIndex, col) in row.withIndex()) {
      if (col != '.' && col.isLetterOrDigit()) {
        val nodeList = nodes.getOrPut(col) { mutableListOf() }
        nodeList.add(Pos(rowIndex, colIndex))
      }
    }
  }
  val antiNodes = mutableSetOf<Pos>()
  nodes.forEach { (_, antennaPos) ->
    if (antennaPos.size < 2) {
      return@forEach
    }
    antennaPos.forEach { ant ->
      antennaPos.forEach { otherAnt ->
        if (ant != otherAnt) {
          val rowDiff = otherAnt.row - ant.row
          val colDiff = otherAnt.col - ant.col
          var curRow = otherAnt.row
          var curCol = otherAnt.col
          while (curRow in lines.indices && curCol in lines[0].indices) {
            antiNodes.add(Pos(curRow, curCol))
            curRow += rowDiff
            curCol += colDiff
          }
          curRow = ant.row
          curCol = ant.col
          while (curRow in lines.indices && curCol in lines[0].indices) {
            antiNodes.add(Pos(curRow, curCol))
            curRow -= rowDiff
            curCol -= colDiff
          }
        }
      }
    }
  }
//  for ((rowIndex, line) in lines.withIndex()) {
//    println(line.mapIndexed { colIndex, char ->
//      if (char == '.' && antiNodes.contains(Pos(rowIndex, colIndex))) {
//        '#'
//      } else {
//        char
//      }
//    }.joinToString(""))
//  }
  return antiNodes.size
}

fun main() {
  val input = readFileAsList("08/input").filter { it.isNotEmpty() }
  // <397
  println("Part 1: ${partOne(input)}")
  println("Part 2: ${partTwo(input)}")
}
