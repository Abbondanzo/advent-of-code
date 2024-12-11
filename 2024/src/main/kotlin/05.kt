import Utils.readFileAsList

/**
 * An update is valid if none of the numbers before it are in that number's rule set.
 *
 * For example: {1: [2,3], 2:[3]}
 * - 2 and 3 cannot come before 1
 * - 3 cannot come before 2
 *
 * Therefore, the following is a valid update:
 * - [1, 2, 3]
 *
 * And the following are examples of an invalid update:
 * - [3, 2, 1]
 * - [1, 3, 2]
 */
private fun isUpdateValid(rules: Map<Int, Set<Int>>, update: List<Int>): Boolean {
  for ((index, item) in update.withIndex()) {
    val itemsBefore = update.take(index)
    val beforeSet = rules[item] ?: continue
    if (itemsBefore.any { beforeSet.contains(it) }) {
      return false
    }
  }
  return true
}

/** Sum the midpoints of all valid rule sets. */
private fun partOne(rules: Map<Int, Set<Int>>, updates: List<List<Int>>): Int {
  var total = 0
  for (update in updates) {
    if (isUpdateValid(rules, update)) {
      val midPoint = update[update.size / 2]
      total += midPoint
    }
  }
  return total
}

/**
 * Given an invalid update, correct the update such that it's valid according to the provided rules.
 */
private fun fixUpdateOrder(rules: Map<Int, Set<Int>>, update: List<Int>): List<Int> {
  val updateCopy = mutableListOf<Int>()
  updateCopy.addAll(update)
  var index = 0
  while (index < updateCopy.size) {
    val item = updateCopy[index]
    val beforeSet = rules[item]
    // If there are no rules for this number, great! Skip it
    if (beforeSet == null) {
      index++
      continue
    }
    val itemsBefore = updateCopy.take(index)
    val firstItemBefore = itemsBefore.indexOfFirst { beforeSet.contains(it) }
    // If all the numbers before this are valid, great! Skip it
    if (firstItemBefore == -1) {
      index++
      continue
    }
    // Move this number before the first offending item in the rules and go back to iterating from
    // the offending
    // number's new spot
    updateCopy.removeAt(index)
    updateCopy.add(firstItemBefore, item)
    index = firstItemBefore + 1
  }
  return updateCopy
}

/** Sum the midpoints of all invalid rule sets after they've been made valid. */
private fun partTwo(rules: Map<Int, Set<Int>>, updates: List<List<Int>>): Int {
  var total = 0
  for (update in updates) {
    if (!isUpdateValid(rules, update)) {
      val fixed = fixUpdateOrder(rules, update)
      val midPoint = fixed[fixed.size / 2]
      total += midPoint
    }
  }
  return total
}

fun main() {
  val input = readFileAsList("05/input").map { it.trim() }

  var readingOrderingRules = true
  val pageOrderingRules = mutableMapOf<Int, Set<Int>>()
  val updates = mutableListOf<List<Int>>()
  for (line in input) {
    if (line.isEmpty()) {
      readingOrderingRules = false
      continue
    }
    if (readingOrderingRules) {
      val split = line.split("|").map(String::toInt)
      val rules = pageOrderingRules.getOrDefault(split[0], emptyList())
      pageOrderingRules[split[0]] = rules.union(setOf(split[1]))
    } else {
      updates.add(line.split(",").map(String::toInt))
    }
  }

  println("Part 1: ${partOne(pageOrderingRules, updates)}")
  println("Part 2: ${partTwo(pageOrderingRules, updates)}")
}
