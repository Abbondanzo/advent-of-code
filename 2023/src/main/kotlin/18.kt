import Utils.readFileAsList
import kotlin.math.absoluteValue

private class Day18 {

  data class Coordinate(
      val x: Long,
      val y: Long,
  )

  enum class Direction {
    RIGHT,
    DOWN,
    LEFT,
    UP,
  }

  data class Line(val direction: Direction, val amount: Int, val color: String) {
    companion object {
      fun fromLine(input: String): Line {
        val split = input.split(" ")
        assert(split.size == 3)
        val direction =
            when (val dir = split[0]) {
              "R" -> Direction.RIGHT
              "D" -> Direction.DOWN
              "L" -> Direction.LEFT
              "U" -> Direction.UP
              else -> error("Unrecognized direction $dir")
            }
        val amount = split[1].toInt()
        val color = split[2].substring(2..7)
        return Line(direction, amount, color)
      }
    }
  }

  data class FixedLine(val direction: Direction, val amount: Long) {
    companion object {

      fun fromBasicLine(input: String) {

      }

      fun fromBadLine(input: String): FixedLine {
        val split = input.split(" ")
        assert(split.size == 3)
        // (#XXXXXX)
        val color = split[2].substring(2..6)
        val direction =
            when (val dir = split[2][7]) {
              '0' -> Direction.RIGHT
              '1' -> Direction.DOWN
              '2' -> Direction.LEFT
              '3' -> Direction.UP
              else -> error("Unrecognized direction $dir")
            }
        val amount = color.toLong(16)
        return FixedLine(direction, amount)
      }
    }
  }

  private fun isInside(coordinate: Coordinate, walls: Set<Coordinate>): Boolean {
    val sortedX = walls.sortedBy { it.x }
    val sortedY = walls.sortedBy { it.y }
    val minX = sortedX.first().x
    val hasLeft = (coordinate.x downTo minX).any { walls.contains(Coordinate(it, coordinate.y)) }
    if (!hasLeft) {
      return false
    }
    val maxX = sortedX.last().x
    val hasRight = (coordinate.x..maxX).any { walls.contains(Coordinate(it, coordinate.y)) }
    if (!hasRight) {
      return false
    }
    val minY = sortedY.first().y
    val hasUp = (coordinate.y downTo minY).any { walls.contains(Coordinate(coordinate.x, it)) }
    if (!hasUp) {
      return false
    }
    val maxY = sortedY.last().y
    val hasDown = (coordinate.y..maxY).any { walls.contains(Coordinate(coordinate.x, it)) }
    return hasDown
  }

  private fun floodFill(walls: Set<Coordinate>): Int {
    val fullSet = mutableSetOf<Coordinate>()
    fullSet.addAll(walls)
    val firstWall = walls.first()
    val startingPoints =
        listOf(
            Coordinate(firstWall.x + 1, firstWall.y + 1),
            Coordinate(firstWall.x - 1, firstWall.y + 1),
            Coordinate(firstWall.x + 1, firstWall.y - 1),
            Coordinate(firstWall.x - 1, firstWall.y + 1),
        )
    val startingPoint = startingPoints.firstOrNull { isInside(it, walls) }
    if (startingPoint == null) {
      error("No starting point is within walls (checked $startingPoints)")
    }
    val toCheck = mutableSetOf(startingPoint)
    while (toCheck.isNotEmpty()) {
      val first = toCheck.first()
      toCheck.remove(first)
      fullSet.add(first)
      val neighbors =
          listOf(
              Coordinate(first.x, first.y - 1), // U
              Coordinate(first.x, first.y + 1), // D
              Coordinate(first.x - 1, first.y), // L
              Coordinate(first.x + 1, first.y), // R
          )
      for (neighbor in neighbors) {
        if (!toCheck.contains(neighbor) && !fullSet.contains(neighbor)) {
          toCheck.add(neighbor)
        }
      }
    }
    return fullSet.size
  }

  fun partOne(input: List<Line>): Int {
    val walls = mutableSetOf<Coordinate>()
    var cur = Coordinate(0, 0)
    walls.add(cur)
    for (line in input) {
      val xStep =
          when (line.direction) {
            Direction.UP,
            Direction.DOWN -> 0
            Direction.LEFT -> -1
            Direction.RIGHT -> 1
          }
      val yStep =
          when (line.direction) {
            Direction.LEFT,
            Direction.RIGHT -> 0
            Direction.UP -> -1
            Direction.DOWN -> 1
          }
      for (step in 1..line.amount) {
        cur = Coordinate(cur.x + xStep, cur.y + yStep)
        walls.add(cur)
      }
    }
    return floodFill(walls)
  }

  fun partTwo(input: List<FixedLine>): Long {
    var total = 1L
    var width = 0L
    for (line in input) {
      when (line.direction) {
        Direction.RIGHT -> {
          width += line.amount
          total += line.amount
        }
        Direction.LEFT -> {
          width -= line.amount
        }
        Direction.DOWN -> {
          total += line.amount * width
        }
        Direction.UP -> {
          total -= line.amount * (width - 1)
        }
      }
    }

    return total
  }

//  fun partTwo(input: List<Line>): Long {
//    val corners = mutableSetOf<Coordinate>()
//    var cur = Coordinate(0, 0)
//    corners.add(cur)
//    for (line in input) {
//      val xStep =
//          when (line.direction) {
//            Direction.UP,
//            Direction.DOWN -> 0
//            Direction.LEFT -> -1
//            Direction.RIGHT -> 1
//          }
//      val yStep =
//          when (line.direction) {
//            Direction.LEFT,
//            Direction.RIGHT -> 0
//            Direction.UP -> -1
//            Direction.DOWN -> 1
//          }
//      cur = Coordinate(cur.x + (xStep * line.amount), cur.y + (yStep * line.amount))
//      corners.add(cur)
//    }
//    // Sort by increasing y, then increasing x
//    val increasingCorners = corners.groupBy { it.y }.mapValues { entry ->
//      entry.value.sortedBy(Coordinate::x)
//    }
//    val keys = increasingCorners.keys.sorted()
//
//
//    var total = 0L
//
//    var prevKey = keys.first()
//    val firstRow = increasingCorners[prevKey]!!
//    var prevRegions = (firstRow.indices step 2).map { index ->
//      IntRange(firstRow[index].x, firstRow[index + 1].x)
//    }
//
//    for (key in keys.drop(1)) {
//      val row = increasingCorners[key]!!
//      for (region in prevRegions) {
//        total += (1 + key - prevKey) * (1 + region.last - region.first)
//      }
//      val rowRegions = (row.indices step 2).map { index ->
//        IntRange(row[index].x, row[index + 1].x)
//      }
//      if (key == keys.last()) {
//        break
//      }
//      println("START $key $rowRegions")
//      val modifiableList = prevRegions.toMutableList()
//      val toRemove = mutableListOf<IntRange>()
//      for (index in modifiableList.indices) {
//        val maybeJoinLeft = rowRegions.find { newRegion -> newRegion.last == modifiableList[index].first }
//        val maybeShrinkLeft = rowRegions.find { newRegion -> newRegion.first == modifiableList[index].first }
//        if (maybeJoinLeft != null) {
//          modifiableList[index] = IntRange(maybeJoinLeft.first, modifiableList[index].last)
//          println(modifiableList[index])
//        } else if (maybeShrinkLeft != null) {
//          modifiableList[index] = IntRange(maybeShrinkLeft.last, modifiableList[index].last)
//          total -=
//          println(modifiableList[index])
//        }
//        val maybeJoinRight = rowRegions.find { newRegion -> newRegion.first == modifiableList[index].last }
//        val maybeShrinkRight = rowRegions.find { newRegion -> newRegion.last == modifiableList[index].last }
//        if (maybeJoinRight != null) {
//          modifiableList[index] = IntRange(modifiableList[index].first, maybeJoinRight.last)
//          println(modifiableList[index])
//        } else if (maybeShrinkRight != null) {
//          modifiableList[index] = IntRange(modifiableList[index].first, maybeShrinkRight.first)
//          println(modifiableList[index])
//        }
//      }
//
//
//      prevRegions = modifiableList
//      prevKey = key
//
//
//      println("$key $modifiableList")
//    }
//
//
//    return total
//  }
}

fun main() {
  val input = readFileAsList("18/input").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${Day18().partOne(input.map(Day18.Line::fromLine))}")
//  println("Part 2: ${Day18().partTwo(input.map(Day18.FixedLine::fromLine))}")
}
