import Utils.readFileAsList

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
        val passesRule = when (rule.condition.operator) {
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

  fun partTwo(input: List<String>) {
    // TODO("Not yet implemented")
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
  println("Part 2: ${Day19.partTwo(input)}")
}
