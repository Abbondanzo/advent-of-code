import Utils.readFileAsList

private object Day18 {

  enum class Direction {
    RIGHT,
    DOWN,
    LEFT,
    UP,
  }

  data class InputLine(val direction: Direction, val amount: Long, val color: String) {
    companion object {
      fun fromPartOneLine(input: String): InputLine {
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
        val amount = split[1].toLong()
        val color = split[2].substring(2..7)
        return InputLine(direction, amount, color)
      }

      fun fromPartTwoLine(input: String): InputLine {
        val split = input.split(" ")
        assert(split.size == 3)
        // (#XXXXXD)
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
        return InputLine(direction, amount, "")
      }
    }
  }

  fun findArea(input: List<InputLine>): Long {
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
}

fun main() {
  val input = readFileAsList("18/input").map(String::trim).filter(String::isNotEmpty)
  println("Part 1: ${Day18.findArea(input.map(Day18.InputLine::fromPartOneLine))}")
  println("Part 2: ${Day18.findArea(input.map(Day18.InputLine::fromPartTwoLine))}")
}
