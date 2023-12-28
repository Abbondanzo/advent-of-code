import Utils.readFileAsList
import kotlin.math.absoluteValue
import kotlin.math.max

private object Day24 {

  private const val DOUBLE_START = 200000000000000.0
  private const val DOUBLE_END = 400000000000000.0

  data class Coordinate(val x: Double, val y: Double, val z: Double) {

    operator fun plus(other: Coordinate): Coordinate {
      return Coordinate(x + other.x, y + other.y, z + other.z)
    }

    operator fun minus(other: Coordinate): Coordinate {
      return Coordinate(x - other.x, y - other.y, z - other.z)
    }

    operator fun times(value: Long): Coordinate {
      return Coordinate(x * value, y * value, z * value)
    }
  }

  data class Hailstone(val position: Coordinate, val velocity: Coordinate) {
    val pointSlope by lazy {
      val slope = velocity.y / velocity.x
      val remainder = position.y - position.x * slope
      PointSlope(slope, remainder)
    }

    fun subtractRockVelocity(rockVelocity: Coordinate): Hailstone {
      return Hailstone(position, velocity - rockVelocity)
    }

    fun getTimeToPoint(point: Coordinate): Double {
      if (velocity.x != 0.0) {
        return (point.x - position.x) / velocity.x
      }
      if (velocity.y != 0.0) {
        return (point.y - position.y) / velocity.y
      }
      if (velocity.z != 0.0) {
        return (point.z - position.z) / velocity.z
      }
      error("Can never reach another point if velocity is 0")
    }
  }

  data class PointSlope(val slope: Double, val remainder: Double) {
    fun intersect2D(other: PointSlope): Pair<Double, Double>? {
      if (slope == other.slope) {
        return null
      }
      if (slope.absoluteValue == Double.POSITIVE_INFINITY && other.slope.absoluteValue == Double.POSITIVE_INFINITY) {
        return null
      }
      if (slope.isNaN() || other.slope.isNaN()) {
        return null
      }
      if (slope.absoluteValue == Double.POSITIVE_INFINITY) {
        val x = remainder
        val y = other.slope * x
        return x to y
      }
      if (other.slope.absoluteValue == Double.POSITIVE_INFINITY) {
        val x = other.remainder
        val y = slope * x
        return x to y
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
    val pointSlopes = input.map { hailstone -> hailstone.pointSlope }
    fun isInPast(hailstone: Hailstone, intersection: Pair<Double, Double>): Boolean {
      val point = hailstone.position
      val nextPoint = hailstone.position + hailstone.velocity
      if ((intersection.first - point.x).absoluteValue <
        (intersection.first - nextPoint.x).absoluteValue
      ) {
        return true
      }
      return (intersection.second - point.y).absoluteValue <
          (intersection.second - nextPoint.y).absoluteValue
    }

    var inTestArea = 0
    val rangeToCheck = start..end
    for (i in pointSlopes.indices) {
      for (j in (i + 1)..<pointSlopes.size) {
        val intersection = pointSlopes[i].intersect2D(pointSlopes[j])
        if (intersection != null &&
          intersection.first in rangeToCheck &&
          intersection.second in rangeToCheck &&
          !isInPast(input[i], intersection) &&
          !isInPast(input[j], intersection)
        ) {
          inTestArea++
        }
      }
    }
    return inTestArea
  }

  fun partOne(input: List<Hailstone>): Int {
    return get2DIntersections(input, DOUBLE_START, DOUBLE_END)
  }

  private fun getHailZ(point: Coordinate, hailstoneA: Hailstone, hailstoneB: Hailstone): Double? {
    val timeA = hailstoneA.getTimeToPoint(point)
    val timeB = hailstoneB.getTimeToPoint(point)
    if (timeA == timeB) {
      val zA = hailstoneA.position.z + hailstoneA.velocity.z * timeA
      val zB = hailstoneB.position.z + hailstoneB.velocity.z * timeB
      if (zA != zB) {
        error("Illegal overlap")
      }
      return null
    }
    val zDiff = hailstoneA.position.z - hailstoneB.position.z
    val zTimeDiff = timeA * hailstoneA.velocity.z - timeB * hailstoneB.velocity.z
    return (zDiff + zTimeDiff) / (timeA - timeB)
  }

  private fun checkWithTolerance(pairA: Pair<Double, Double>, pairB: Pair<Double, Double>): Boolean {
    val diffX = (pairA.first - pairB.first).absoluteValue
    val diffY = (pairA.second - pairB.second).absoluteValue
    val tolerance = 0.00000001 // we should probably flip over to BigDecimal, but hey
    return (diffX / pairA.first) < tolerance && (diffY / pairB.second) < tolerance
  }

  private fun searchWithMaxes(input: List<Hailstone>, maxes: Int): Long {
    for (x in -maxes..maxes) {
      for (y in -maxes..maxes) {
        val rockVelocity = Coordinate(x.toDouble(), y.toDouble(), 0.0)
        val hailstoneA = input[0].subtractRockVelocity(rockVelocity)
        var runningIntersection: Pair<Double, Double>? = null

        for (b in 1..<input.size) {
          val hailstoneB = input[b].subtractRockVelocity(rockVelocity)
          val intersection = hailstoneA.pointSlope.intersect2D(hailstoneB.pointSlope)
          if (intersection != null && (runningIntersection == null || checkWithTolerance(
              runningIntersection,
              intersection
            ))
          ) {
            runningIntersection = intersection
          } else {
            runningIntersection = null
            break
          }
        }
        if (runningIntersection == null) {
          continue
        }
        val intersection = Coordinate(runningIntersection.first, runningIntersection.second, 0.0)
        var runningRockZ: Double? = null
        for (b in 1..<input.size) {
          val hailstoneB = input[b].subtractRockVelocity(rockVelocity)
          val maybeRockZ = getHailZ(intersection, hailstoneA, hailstoneB)
          if (runningRockZ == null) {
            runningRockZ = maybeRockZ
          } else if (runningRockZ != maybeRockZ) {
            runningRockZ = null
            break
          }
        }
        if (runningRockZ != null) {
          val z =
            hailstoneA.position.z + hailstoneA.getTimeToPoint(intersection) * (hailstoneA.velocity.z - runningRockZ)
          return (intersection.x + intersection.y + z).toLong()
        }
      }
    }

    error("Could not find with maxes $maxes")
  }
  
  fun partTwo(input: List<Hailstone>): Long {
    return searchWithMaxes(input, 500)
  }
}

fun main() {
  val input = readFileAsList("24/input").map(String::trim).filter(String::isNotEmpty)
  val hailstones = Day24.parseInput(input)
  println("Part 1: ${Day24.partOne(hailstones)}")
  println("Part 2: ${Day24.partTwo(hailstones)}")
}
