import Utils.readFileAsList

private fun hashmap(value: String): Int {
  var curValue = 0
  for (char in value) {
    curValue += char.code
    curValue *= 17
    curValue %= 256
  }
  return curValue
}

private fun partOne(input: String): Int {
  val values =
      input.split(",").map {
        return@map hashmap(it)
      }
  return values.reduce { acc, i -> acc + i }
}

private fun partTwo(input: String): Int {
  val boxes = mutableMapOf<Int, MutableMap<String, Int>>()

  input.split(",").forEach {
    if (it.contains("=")) {
      val value = it.split("=")
      assert(value.size == 2)
      val box = hashmap(value[0])
      val curBox = boxes.getOrPut(box) { mutableMapOf() }
      curBox[value[0]] = value[1].toInt()
    } else if (it.contains("-")) {
      val value = it.split("-")
      val box = hashmap(value[0])
      val curBox = boxes[box]
      if (curBox != null && curBox.containsKey(value[0])) {
        curBox.remove(value[0])
      }
    }
  }

  var total = 0
  for (x in boxes.entries) {
    for ((slotIndex, slotEntry) in x.value.entries.withIndex()) {
      val toAdd = (x.key + 1) * (slotIndex + 1) * (slotEntry.value)
      total += toAdd
    }
  }
  return total
}

fun main() {
  val input = readFileAsList("15/input").map(String::trim).filter(String::isNotEmpty)
  assert(input.size == 1)
  println("Part 1: ${partOne(input[0])}")
  println("Part 2: ${partTwo(input[0])}")
}
