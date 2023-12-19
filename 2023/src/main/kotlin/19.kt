import Utils.readFileAsList
import kotlin.math.max
import kotlin.math.min

private object Day19 {

  enum class Operator {
    LESS_THAN,
    GREATER_THAN,
  }

  data class Condition(val letter: Char, val operator: Operator, val amount: Int)

  data class Rule(val condition: Condition, val sendTo: String)

  data class Workflow(val name: String, val rules: List<Rule>, val sendTo: String) {
    fun processRating(rating: Map<Char, Int>): String {
      for (rule in rules) {
        val toCheck = rating[rule.condition.letter]!!
        val passesRule =
            when (rule.condition.operator) {
              Operator.LESS_THAN -> toCheck < rule.condition.amount
              Operator.GREATER_THAN -> toCheck > rule.condition.amount
            }
        if (passesRule) {
          return rule.sendTo
        }
      }
      return sendTo
    }
  }

  fun parseWorkflowLine(line: String): Workflow {
    val workflowName = line.substringBefore("{")
    val rawOperations = line.substringAfter("{").substringBefore("}").split(",")
    val rules =
        rawOperations.dropLast(1).map { rawOperation ->
          val rawCondition = rawOperation.substringBefore(":")
          val letter = rawCondition[0]
          val operator =
              when (val rawOperator = rawCondition[1]) {
                '<' -> Operator.LESS_THAN
                '>' -> Operator.GREATER_THAN
                else -> error("Unrecognized operator $rawOperator")
              }
          val amount = rawCondition.substring(2).toInt()
          val condition = Condition(letter, operator, amount)
          val sendTo = rawOperation.substringAfter(":")
          return@map Rule(condition, sendTo)
        }
    val lastRule = rawOperations.last()
    return Workflow(workflowName, rules, lastRule)
  }

  fun parseRatingLine(line: String): Map<Char, Int> {
    val groupings = line.substringAfter("{").substringBefore("}").split(",")
    val ratings = mutableMapOf<Char, Int>()
    groupings.forEach { grouping ->
      val ratingChar = grouping[0]
      val amount = grouping.substring(2).toInt()
      ratings[ratingChar] = amount
    }
    return ratings
  }

  private fun isRatingAccepted(workflows: Map<String, Workflow>, rating: Map<Char, Int>): Boolean {
    var current = workflows["in"]!!
    while (true) {
      val sendTo = current.processRating(rating)
      if (sendTo == "A") {
        return true
      }
      if (sendTo == "R") {
        return false
      }
      current = workflows[sendTo]!!
    }
  }

  fun partOne(workflows: Map<String, Workflow>, ratings: List<Map<Char, Int>>): Int {
    var total = 0
    for (rating in ratings) {
      if (isRatingAccepted(workflows, rating)) {
        total += rating.values.reduce { acc, i -> acc + i }
      }
    }
    return total
  }

  data class Combination(val x: IntRange, val m: IntRange, val a: IntRange, val s: IntRange) {

    private fun flattenRange(a: IntRange, b: IntRange): IntRange? {
      val range = IntRange(max(a.first, b.first), min(a.last, b.last))
      if (range.first > range.last) {
        return null
      }
      return range
    }

    fun flatten(other: Combination): Combination? {
      val newX = flattenRange(x, other.x) ?: return null
      val newM = flattenRange(m, other.m) ?: return null
      val newA = flattenRange(a, other.a) ?: return null
      val newS = flattenRange(s, other.s) ?: return null
      return Combination(newX, newM, newA, newS)
    }

    fun size(): Long {
      return (x.last - x.first + 1).toLong() *
          (m.last - m.first + 1).toLong() *
          (a.last - a.first + 1).toLong() *
          (s.last - s.first + 1).toLong()
    }

    companion object {
      val DEFAULT_RANGE = (1..4000)
      val DEFAULT = Combination(DEFAULT_RANGE, DEFAULT_RANGE, DEFAULT_RANGE, DEFAULT_RANGE)

      fun fromCondition(condition: Condition): Pair<Combination, Combination> {
        val successRange =
            when (condition.operator) {
              Operator.LESS_THAN -> IntRange(DEFAULT_RANGE.first, condition.amount - 1)
              Operator.GREATER_THAN -> IntRange(condition.amount + 1, DEFAULT_RANGE.last)
            }
        val failRange =
            when (condition.operator) {
              Operator.LESS_THAN -> IntRange(condition.amount, DEFAULT_RANGE.last)
              Operator.GREATER_THAN -> IntRange(DEFAULT_RANGE.first, condition.amount)
            }
        return when (condition.letter) {
          'x' -> Pair(DEFAULT.copy(x = successRange), DEFAULT.copy(x = failRange))
          'm' -> Pair(DEFAULT.copy(m = successRange), DEFAULT.copy(m = failRange))
          'a' -> Pair(DEFAULT.copy(a = successRange), DEFAULT.copy(a = failRange))
          's' -> Pair(DEFAULT.copy(s = successRange), DEFAULT.copy(s = failRange))
          else -> error("Unrecognized letter ${condition.letter}")
        }
      }
    }
  }

  fun partTwo(workflows: Map<String, Workflow>): Long {
    val mutableWorkflows = workflows.toMutableMap()
    val acceptRanges = mutableMapOf<String, List<Combination>>()
    fun canProcess(sending: String): Boolean {
      return sending in "AR" || acceptRanges.containsKey(sending)
    }
    while (mutableWorkflows.isNotEmpty()) {
      val keysToRemove = mutableSetOf<String>()
      for (entry in mutableWorkflows.entries) {
        val readyToProcess =
            entry.value.rules.all { canProcess(it.sendTo) } && canProcess(entry.value.sendTo)
        if (readyToProcess) {
          val combinations = mutableListOf<Combination>()
          var runningStart: Combination? = Combination.DEFAULT
          for (rule in entry.value.rules) {
            if (runningStart == null) {
              break
            }
            val (success, fail) = Combination.fromCondition(rule.condition)
            when (rule.sendTo) {
              "A" -> {
                val toSucceed = runningStart.flatten(success)
                if (toSucceed != null) combinations.add(toSucceed)
              }
              "R" -> {
                // Skip!
              }
              else -> {
                for (otherCombination in acceptRanges[rule.sendTo]!!) {
                  val toSucceed = success.flatten(otherCombination)
                  if (toSucceed != null) combinations.add(toSucceed)
                }
              }
            }
            runningStart = runningStart.flatten(fail)
          }
          when (entry.value.sendTo) {
            "A" -> {
              if (runningStart != null) {
                combinations.add(runningStart)
              }
            }
            "R" -> {
              // Skip!
            }
            else -> {
              if (runningStart != null) {
                for (otherCombination in acceptRanges[entry.value.sendTo]!!) {
                  val toSucceed = runningStart.flatten(otherCombination)
                  if (toSucceed != null) combinations.add(toSucceed)
                }
              }
            }
          }
          keysToRemove.add(entry.key)
          acceptRanges[entry.key] = combinations
        }
      }
      keysToRemove.forEach { mutableWorkflows.remove(it) }
    }
    val inRange = acceptRanges["in"]!!
    var total = 0L
    for (i in inRange.indices) {
      total += inRange[i].size()
      for (j in (i + 1) ..< inRange.size) {
        val overlap = inRange[i].flatten(inRange[j])
        if (overlap != null) {
          total -= overlap.size()
        }
      }
    }
    return total
  }

  private fun getCombinations(workflow: String, start: Combination, workflows: Map<String, Workflow>): List<Combination> {
    return when (workflow) {
      "A" -> listOf(start)
      "R" -> listOf()
      else -> {
        val combinations = mutableListOf<Combination>()
        var runningStart = start
        val getGot = workflows[workflow]!!
        for (rule in getGot.rules) {
          val (success, fail) = Combination.fromCondition(rule.condition)
          val onSuccess = runningStart.flatten(success)
          if (onSuccess != null) {
            combinations.addAll(getCombinations(rule.sendTo, onSuccess, workflows))
          }
          val onFailure = runningStart.flatten(fail)
          if (onFailure == null) {
            return combinations
          } else {
            runningStart = onFailure
          }
        }
        combinations.addAll(getCombinations(getGot.sendTo, runningStart, workflows))
        return combinations
      }
    }
  }

  fun partTwoRecursive(workflows: Map<String, Workflow>): Long {
    val inRange = getCombinations("in", Combination.DEFAULT, workflows)
    var total = 0L
    for (i in inRange.indices) {
      total += inRange[i].size()
      for (j in (i + 1) ..< inRange.size) {
        val overlap = inRange[i].flatten(inRange[j])
        if (overlap != null) {
          total -= overlap.size()
        }
      }
    }
    return total
  }
}

fun main() {
  val input = readFileAsList("19/input").map(String::trim)
  val workflows = mutableListOf<Day19.Workflow>()
  val ratings = mutableListOf<Map<Char, Int>>()
  var lookingForWorkflow = true
  for (line in input) {
    if (line.isEmpty()) {
      lookingForWorkflow = false
      continue
    }
    if (lookingForWorkflow) {
      workflows.add(Day19.parseWorkflowLine(line))
    } else {
      ratings.add(Day19.parseRatingLine(line))
    }
  }
  val groupedWorkflows = workflows.associateBy { it.name }
  println("Part 1: ${Day19.partOne(groupedWorkflows, ratings)}")
  println("Part 2: ${Day19.partTwoRecursive(groupedWorkflows)}")
}
