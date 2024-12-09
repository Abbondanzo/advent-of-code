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

private data class Block(
  val id: Int,
  val count: Int,
  val space: Int,
)

private fun printBlockList(blockList: List<Block>) {
  val sb = StringBuilder()
  for (block in blockList) {
    sb.append(block.id.toString().repeat(block.count))
    sb.append(".".repeat(block.space))
  }
  println(sb.toString())
}

private fun partTwo(diskMap: List<Pair<Int, Int>>): Long {
//  val newDiskMap = mutableListOf<Block>()
//  diskMap.forEachIndexed { index, mapping -> newDiskMap.add(Block(id = index, count = mapping.first, space = mapping.second)) }
//  println(newDiskMap)
//  var blockIndex = diskMap.size - 1
//  while (blockIndex >= 1) {
//    val itemCount = diskMap[blockIndex].first
//    val blockToSplit = newDiskMap.indexOfFirst { it.space >= itemCount }
//    if (blockToSplit != -1) {
//      val blockToSplitItem = newDiskMap[blockToSplit]
//      // Give remaining space back to prior block
//      val blockToRemove = newDiskMap.indexOfLast { it.id == blockIndex }
//      val blockToRemoveItem = newDiskMap[blockToRemove]
//      newDiskMap.removeAt(blockToRemove)
//      val prevItemBeforeRemove = newDiskMap[blockToRemove - 1]
//      newDiskMap[blockToRemove - 1] = prevItemBeforeRemove.copy(space = prevItemBeforeRemove.space + blockToRemoveItem.count + blockToRemoveItem.space)
//      // Remove space from split block
//      newDiskMap[blockToSplit] = blockToSplitItem.copy(space = 0)
//      val remainingSpace = blockToSplitItem.space - itemCount
//      newDiskMap.add(blockToSplit + 1, blockToRemoveItem.copy(space = remainingSpace))
//      println(newDiskMap)
//    }
//    blockIndex--
//  }
//  var offset = 0
//  var total = 0L
//  for (block in newDiskMap) {
//    for (i in offset..<offset+block.count) {
//      if (block.id != -1) {
//        total += (i * block.id)
//      }
//    }
//    offset += block.count + block.space
//  }
//  println(newDiskMap)


  val blockList = mutableListOf<Block>()
  diskMap.forEachIndexed { index, mapping -> blockList.add(Block(id = index, count = mapping.first, space = mapping.second)) }
  var blockId = diskMap.size - 1
  while (blockId >= 1) {
    val blockSize = diskMap[blockId].first
    val movingBlockIdx = blockList.indexOfLast { it.id == blockId }
    val splitBlockIdx = blockList.indexOfFirst { it.space >= blockSize }
    if (splitBlockIdx != -1 && splitBlockIdx < movingBlockIdx) {
      val splitBlock = blockList[splitBlockIdx]
      // Give remaining space back to prior block
      val movingBlock = blockList[movingBlockIdx]
      blockList.removeAt(movingBlockIdx)
      val beforeMovingBlock = blockList[movingBlockIdx - 1]
      blockList[movingBlockIdx - 1] = beforeMovingBlock.copy(space = beforeMovingBlock.space + movingBlock.count + movingBlock.space)
      // Remove space from split block
      blockList[splitBlockIdx] = splitBlock.copy(space = 0)
      val remainingSpace = splitBlock.space - blockSize
      blockList.add(splitBlockIdx + 1, movingBlock.copy(space = remainingSpace))
      printBlockList(blockList)
    }

    blockId--
  }

  var offset = 0
  var total = 0L
  for (block in blockList) {
    for (i in offset..<offset+block.count) {
      if (block.id != -1) {
        total += (i * block.id)
      }
    }
    offset += block.count + block.space
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

private fun partTwoFill(diskMap: List<Pair<Int, Int>>): Long {
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
  println("Part 2: ${partTwoFill(diskMap)}")
}
