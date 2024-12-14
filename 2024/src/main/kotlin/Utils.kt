object Utils {
  private fun readFile(fileName: String): String {
    return Utils.javaClass.getResource(fileName)?.readText() ?: error("Unable to read $fileName")
  }

  fun readFileAsList(fileName: String): List<String> {
    return readFile(fileName).split("\n").map(String::trim)
  }

  data class Pos(val row: Int, val col: Int) {
    operator fun plus(other: Pos): Pos {
      return Pos(row + other.row, col + other.col)
    }

    operator fun times(other: Pos): Pos {
      return Pos(row * other.row, col * other.col)
    }

    operator fun times(int: Int): Pos {
      return Pos(row * int, col * int)
    }

    fun mod(other: Pos): Pos {
      return Pos(row.mod(other.row), col.mod(other.col))
    }
  }
}
