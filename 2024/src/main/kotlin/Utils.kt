object Utils {
  private fun readFile(fileName: String): String {
    return Utils.javaClass.getResource(fileName)?.readText() ?: error("Unable to read $fileName")
  }

  fun readFileAsList(fileName: String): List<String> {
    return readFile(fileName).split("\n").map(String::trim)
  }

  data class Pos(val row: Int, val col: Int)
}
