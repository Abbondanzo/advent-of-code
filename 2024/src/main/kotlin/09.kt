import Utils.readFileAsList

private fun partOne(diskMap: List<Pair<Int, Int>>): Long {
  val newList = mutableListOf<Int>()
  diskMap.forEachIndexed { index, (count, empty) ->
    newList.addAll(List(count) { index })
    newList.addAll(List(empty) { -1 })
  }
  var index = 0
  while (index < newList.size) {
    while (newList[index] == -1) {
      newList[index] = newList.removeLast()
    }
    index++
  }
  var total = 0L
  for ((idx, item) in newList.withIndex()) {
    total += idx * item
  }
  return total
}

private fun indexOfSpace(list: List<Int>, requiredSpace: Int): Int {
  var index = 0
  var spaceCount = 0
  while (index < list.size) {
    if (list[index] == -1) {
      spaceCount++
    } else {
      spaceCount = 0
    }
    if (spaceCount >= requiredSpace) {
      return index - spaceCount + 1
    }
    index++
  }
  return -1
}

private fun partTwo(diskMap: List<Pair<Int, Int>>): Long {
  val newList = mutableListOf<Int>()
  val offsets = mutableMapOf<Int, Int>()
  diskMap.forEachIndexed { index, (count, empty) ->
    offsets[index] = newList.size
    newList.addAll(List(count) { index })
    newList.addAll(List(empty) { -1 })
  }
  var blockId = diskMap.size - 1
  while (blockId >= 1) {
    val spaceRequired = diskMap[blockId].first
    val oldOffset = offsets[blockId]!!
    val indexToInsert = indexOfSpace(newList, spaceRequired)
    if (indexToInsert != -1 && indexToInsert < oldOffset) {
      for (i in indexToInsert..<indexToInsert + spaceRequired) {
        newList[i] = blockId
      }
      for (i in oldOffset..<oldOffset+spaceRequired) {
        newList[i] = -1
      }
    }
    blockId--
  }
  var total = 0L
  for ((idx, item) in newList.withIndex()) {
    if (item != -1) {
      total += idx * item
    }
  }
  return total
}

fun main() {
  val input = readFileAsList("09/input").filter { it.isNotEmpty() }
  val diskMap = mutableListOf<Pair<Int, Int>>()
  for (i in input[0].indices step 2) {
    val space = if (i + 1 in input[0].indices) input[0][i + 1].digitToInt() else 0
    diskMap.add(input[0][i].digitToInt() to space)
  }
  println("Part 1: ${partOne(diskMap)}")
  println("Part 2: ${partTwo(diskMap)}")
}
