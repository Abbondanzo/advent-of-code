import Utils.readFileAsList
import kotlin.math.absoluteValue
import kotlin.math.min

private object Day22 {

  data class Coordinate(val x: Int, val y: Int, val z: Int) {
    override fun toString(): String {
      return "$x,$y,$z"
    }
  }

  data class Brick(val start: Coordinate, val end: Coordinate) {
    override fun toString(): String {
      return "$start~$end"
    }

    val lowZ: Int
      get() {
        return min(start.z, end.z)
      }

    val height: Int
      get() {
        return (start.z - end.z).absoluteValue + 1
      }

    val xRange: IntRange by lazy { if (start.x <= end.x) start.x..end.x else end.x..start.x }

    val yRange: IntRange by lazy { if (start.y <= end.y) start.y..end.y else end.y..start.y }

    val zRange: IntRange by lazy { if (start.z <= end.z) start.z..end.z else end.z..start.z }

    fun subtractZ(lowerAmount: Int): Brick {
      return Brick(start.copy(z = start.z - lowerAmount), end.copy(z = end.z - lowerAmount))
    }

    fun supports(other: Brick): Boolean {
      if (other.lowZ != lowZ + height) {
        return false
      }

      for (x in xRange) {
        for (y in yRange) {
          if (x in other.xRange && y in other.yRange) {
            return true
          }
        }
      }
      return false
    }
  }

  fun parseInput(input: List<String>): List<Brick> {
    return input.map { line ->
      val rawStart = line.substringBefore("~").split(",").map { it.toInt() }
      val start = Coordinate(rawStart[0], rawStart[1], rawStart[2])
      val rawEnd = line.substringAfter("~").split(",").map { it.toInt() }
      val end = Coordinate(rawEnd[0], rawEnd[1], rawEnd[2])
      return@map Brick(start, end)
    }
  }

  private fun settle(bricks: Set<Brick>): Pair<Set<Brick>, Int> {
    val sortedByLowZ = bricks.sortedBy { it.lowZ }
    val settled = mutableMapOf<String, Int>()
    val newBricks = mutableSetOf<Brick>()

    var deltaCount = 0
    for (brick in sortedByLowZ) {
      var maxZ = 1
      for (x in brick.xRange) {
        for (y in brick.yRange) {
          val key = "$x-$y"
          val value = settled.getOrDefault(key, 1)
          if (value > maxZ) {
            maxZ = value
          }
        }
      }
      val zDelta = brick.lowZ - maxZ
      if (zDelta > 0) {
        deltaCount++
      }
      newBricks.add(brick.subtractZ(zDelta))
      maxZ += brick.height
      for (x in brick.xRange) {
        for (y in brick.yRange) {
          val key = "$x-$y"
          settled[key] = maxZ
        }
      }
    }
    return newBricks to deltaCount
  }

  private fun printBricks(bricks: List<Brick>) {
    val maxX = bricks.maxOf { it.xRange.last }
    val maxY = bricks.maxOf { it.yRange.last }
    val maxZ = bricks.maxOf { it.lowZ + it.height }
    for (z in maxZ downTo 0) {
      val firstString =
          (0..maxX)
              .map { x -> if (bricks.any { x in it.xRange && z in it.zRange }) 'X' else '.' }
              .joinToString("")
      val secondString =
          (0..maxY)
              .map { y -> if (bricks.any { y in it.yRange && z in it.zRange }) 'X' else '.' }
              .joinToString("")
      val zString = z.toString().padStart(4, '0')
      println("$firstString $zString $secondString")
    }
  }

  fun partOne(bricks: List<Brick>): Int {
    val (settledBricks) = settle(bricks.toSet())
    return settledBricks.count { brick ->
      val newSet = settledBricks.minus(brick)
      val (settledNewSet) = settle(newSet)
      newSet.subtract(settledNewSet).isEmpty()
    }
  }

  fun partTwo(bricks: List<Brick>): Int {
    val (settledBricks) = settle(bricks.toSet())
    val fallCounts =
        settledBricks.map { brick ->
          val newSet = settledBricks.minus(brick)
          val (_, fallCount) = settle(newSet)
          fallCount
        }
    return fallCounts.sum()
  }
}

fun main() {
  val input = readFileAsList("22/input").map(String::trim).filter(String::isNotEmpty)
  val bricks = Day22.parseInput(input)
  println("Part 1: ${Day22.partOne(bricks)}")
  println("Part 2: ${Day22.partTwo(bricks)}")
}
