import Utils.readFileAsList
import kotlin.math.max

private object Day16 {

  data class XY(
      val x: Int,
      val y: Int,
  ) {
    fun add(other: XY): XY {
      return XY(x + other.x, y + other.y)
    }

    operator fun plus(other: XY): XY {
      return XY(x + other.x, y + other.y)
    }
  }

  data class Beam(val pos: XY, val step: XY)

  private fun getEnergizeCount(startBeam: Beam, input: List<String>): Int {
    val visited = mutableSetOf<XY>()
    val beamQueue = mutableListOf(startBeam)
    val toIgnore = mutableSetOf<Beam>()
    while (beamQueue.isNotEmpty()) {
      var beam = beamQueue.removeAt(0)
      toIgnore.add(beam)
      while (true) {
        visited.add(beam.pos)
        val nextPos = beam.pos + beam.step
        // Check outside
        if (nextPos.x !in 0 ..< input[0].length || nextPos.y !in input.indices) {
          break
        }
        val nextChar = input[nextPos.y][nextPos.x]
        when (nextChar) {
          '/' -> {
            val newStep = XY(-beam.step.y, -beam.step.x)
            beam = Beam(nextPos, newStep)
          }
          '\\' -> {
            val newStep = XY(beam.step.y, beam.step.x)
            beam = Beam(nextPos, newStep)
          }
          '-' -> {
            if (beam.step.y != 0) {
              val left = Beam(nextPos, XY(-1, 0))
              if (!toIgnore.contains(left)) {
                beamQueue.add(left)
              }
              val right = Beam(nextPos, XY(1, 0))
              if (!toIgnore.contains(right)) {
                beamQueue.add(right)
              }
              break
            } else {
              beam = Beam(nextPos, beam.step)
            }
          }
          '|' -> {
            if (beam.step.x != 0) {
              val up = Beam(nextPos, XY(0, -1))
              if (!toIgnore.contains(up)) {
                beamQueue.add(up)
              }
              val down = Beam(nextPos, XY(0, 1))
              if (!toIgnore.contains(down)) {
                beamQueue.add(down)
              }
              break
            } else {
              beam = Beam(nextPos, beam.step)
            }
          }
          else -> {
            beam = Beam(nextPos, beam.step)
          }
        }
      }
    }
    return visited.size - 1 // Remove outside beam
  }

  fun partOne(input: List<String>): Int {
    return getEnergizeCount(Beam(XY(-1, 0), XY(1, 0)), input)
  }

  fun partTwo(input: List<String>): Int {
    var maxTiles = Int.MIN_VALUE
    // Left edge
    for (y in input.indices) {
      val beam = Beam(XY(-1, y), XY(1, 0))
      maxTiles = max(maxTiles, getEnergizeCount(beam, input))
    }
    // Right edge
    for (y in input.indices) {
      val beam = Beam(XY(input[0].length, y), XY(-1, 0))
      maxTiles = max(maxTiles, getEnergizeCount(beam, input))
    }
    // Top edge
    for (x in 0 ..< input[0].length) {
      val beam = Beam(XY(x, -1), XY(0, 1))
      maxTiles = max(maxTiles, getEnergizeCount(beam, input))
    }
    // Bottom edge
    for (x in 0 ..< input[0].length) {
      val beam = Beam(XY(x, input.size), XY(0, -1))
      maxTiles = max(maxTiles, getEnergizeCount(beam, input))
    }
    return maxTiles
  }
}

fun main() {
  val input = readFileAsList("16/input").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${Day16.partOne(input)}")
  println("Part 2: ${Day16.partTwo(input)}")
}
