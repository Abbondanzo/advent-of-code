import Utils.readFileAsList
import kotlin.math.absoluteValue

private object Day24 {

  private const val DOUBLE_START = 200000000000000.0
  private const val DOUBLE_END = 400000000000000.0

  data class Coordinate(val x: Double, val y: Double, val z: Double) {
    operator fun plus(other: Coordinate): Coordinate {
      return Coordinate(x + other.x, y + other.y, z + other.z)
    }

    operator fun times(value: Double): Coordinate {
      return Coordinate(x * value, y * value, z * value)
    }
  }

  data class Hailstone(val position: Coordinate, val velocity: Coordinate)

  data class PointSlope(val slope: Double, val remainder: Double) {
    fun intersect2D(other: PointSlope): Pair<Double, Double>? {
      if (slope == other.slope) {
        return null
      }
      val x = (remainder - other.remainder) / (other.slope - slope)
      val y = x * slope + remainder
      return x to y
    }
  }

  fun parseInput(input: List<String>): List<Hailstone> {
    return input.map { line ->
      val rawPosition = line.substringBefore("@").split(",").map(String::trim).map(String::toDouble)
      assert(rawPosition.size == 3)
      val position = Coordinate(rawPosition[0], rawPosition[1], rawPosition[2])
      val rawVelocity = line.substringAfter("@").split(",").map(String::trim).map(String::toDouble)
      assert(rawVelocity.size == 3)
      val velocity = Coordinate(rawVelocity[0], rawVelocity[1], rawVelocity[2])
      Hailstone(position, velocity)
    }
  }

  private fun get2DIntersections(input: List<Hailstone>, start: Double, end: Double): Int {
    val pointSlopes =
        input.map { hailstone ->
          val slope = hailstone.velocity.y / hailstone.velocity.x
          val remainder = hailstone.position.y - (hailstone.position.x * slope)
          PointSlope(slope, remainder)
        }
    fun isInPast(hailstone: Hailstone, intersection: Pair<Double, Double>): Boolean {
      val point = hailstone.position
      val nextPoint = hailstone.position + hailstone.velocity
      if ((intersection.first - point.x).absoluteValue <
          (intersection.first - nextPoint.x).absoluteValue) {
        return true
      }
      return (intersection.second - point.y).absoluteValue <
          (intersection.second - nextPoint.y).absoluteValue
    }
    var inTestArea = 0
    val rangeToCheck = start..end
    for (i in pointSlopes.indices) {
      for (j in (i + 1) ..< pointSlopes.size) {
        val intersection = pointSlopes[i].intersect2D(pointSlopes[j])
        if (intersection != null &&
            intersection.first in rangeToCheck &&
            intersection.second in rangeToCheck &&
            !isInPast(input[i], intersection) &&
            !isInPast(input[j], intersection)) {
          inTestArea++
        }
      }
    }
    return inTestArea
  }

  fun partOne(input: List<Hailstone>): Int {
    return get2DIntersections(input, DOUBLE_START, DOUBLE_END)
  }

  fun partTwo(input: List<String>) {
    // TODO("Not yet implemented")
  }
}

fun main() {
  val input = readFileAsList("24/input").map(String::trim).filter(String::isNotEmpty)
  val hailstones = Day24.parseInput(input)
  println("Part 1: ${Day24.partOne(hailstones)}")
  println("Part 2: ${Day24.partTwo(input)}")
}
