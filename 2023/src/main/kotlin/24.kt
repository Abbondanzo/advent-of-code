import Utils.readFileAsList
import kotlin.math.absoluteValue

private object Day24 {

  private const val DOUBLE_START = 200000000000000.0
  private const val DOUBLE_END = 400000000000000.0

  data class Coordinate(val x: Long, val y: Long, val z: Long) {

    private fun gcd(a: Long, b: Long): Long {
      var curA = a.absoluteValue
      var curB = b.absoluteValue
      while (curA != curB) {
        if (curA > curB) {
          curA -= curB
        } else {
          curB -= curA
        }
      }
      return curA
    }

    fun gcd(): Long {
      if (x == 0L || y == 0L || z == 0L) {
        return 0
      }
      return gcd(z, gcd(x, y))
    }

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

  data class Hailstone(val position: Coordinate, val velocity: Coordinate)

  private data class PointSlope(val slope: Double, val remainder: Double) {
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
      val rawPosition = line.substringBefore("@").split(",").map(String::trim).map(String::toLong)
      assert(rawPosition.size == 3)
      val position = Coordinate(rawPosition[0], rawPosition[1], rawPosition[2])
      val rawVelocity = line.substringAfter("@").split(",").map(String::trim).map(String::toLong)
      assert(rawVelocity.size == 3)
      val velocity = Coordinate(rawVelocity[0], rawVelocity[1], rawVelocity[2])
      Hailstone(position, velocity)
    }
  }

  private fun get2DIntersections(input: List<Hailstone>, start: Double, end: Double): Int {
    val pointSlopes =
        input.map { hailstone ->
          val slope = hailstone.velocity.y.toDouble() / hailstone.velocity.x.toDouble()
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

  private fun bruteForce(input: List<Hailstone>, maxDelta: Long) {
    println(maxDelta)
    for (i in input.indices) {
      val a = input[i]
      for (t1 in 0L..maxDelta) {
        val newAPosition = a.position + a.velocity * t1
        for (j in input.indices) {
          if (j == i) {
            continue
          }
          val b = input[j]
          for (t2 in 0L..maxDelta) {
            val newBPosition = b.position + b.velocity * (t1 + t2)
            val diff = newBPosition - newAPosition
            for (k in input.indices) {
              if (k == j || k == i) {
                continue
              }
              val c = input[k]
              for (t3 in 0L..maxDelta) {
                val newCPosition = c.position + c.velocity * (t1 + t2 + t3)
                val otherDiff = newCPosition - newBPosition
                if (diff == otherDiff) {
                  error("FAN! [$t1 $t2 $t3] $newAPosition $newBPosition $newCPosition")
                }
              }
            }
          }
        }
      }
    }
  }

  fun partTwo(input: List<Hailstone>) {
    var i = 1L
    while (i < 10000) {
      bruteForce(input, i)
      i++
    }
  }
}

fun main() {
  val input = readFileAsList("24/input").map(String::trim).filter(String::isNotEmpty)
  val hailstones = Day24.parseInput(input)
  println("Part 1: ${Day24.partOne(hailstones)}")
  println("Part 2: ${Day24.partTwo(hailstones)}")
}
