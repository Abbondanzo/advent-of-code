import java.io.File

object Utils {
    fun readFile(fileName: String): String {
        return Utils.javaClass.getResource(fileName)?.readText() ?: error("Unable to read $fileName")
    }

    fun readFileAsList(fileName: String): List<String> {
        return readFile(fileName).split("\n")
    }
}
