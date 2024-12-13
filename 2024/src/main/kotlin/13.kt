import Utils.readFileAsList

private fun solveMachine(machine: Machine): Button? {
  // Solve system of equations using determinant
  // Ax+By=C -> buttonA.x * coinsA + buttonB.x * coinsB = prize.x
  // Dx+Ey=F -> buttonA.y * coinsA + buttonB.y * coinsB = prize.y

  val xNumerator = machine.prize.x * machine.buttonB.y - machine.buttonB.x * machine.prize.y
  val yNumerator = machine.buttonA.x * machine.prize.y - machine.prize.x * machine.buttonA.y
  val denominator = machine.buttonA.x * machine.buttonB.y - machine.buttonB.x * machine.buttonA.y

  if (xNumerator % denominator == 0L && yNumerator % denominator == 0L) {
    val x = xNumerator / denominator
    val y = yNumerator / denominator
    return Button(x, y)
  }

  return null
}

private fun partOne(machines: List<Machine>): Long {
  var total = 0L
  machines.forEach {
    val maybeButton = solveMachine(it)
    if (maybeButton != null) {
      total += 3L * maybeButton.x
      total += maybeButton.y
    }
  }
  return total
}

private fun partTwo(machines: List<Machine>): Long {
  val increase = 10000000000000L
  val fixedMachines =
      machines.map {
        it.copy(prize = it.prize.copy(x = it.prize.x + increase, y = it.prize.y + increase))
      }
  var total = 0L
  fixedMachines.forEach {
    val maybeButton = solveMachine(it)
    if (maybeButton != null) {
      total += 3L * maybeButton.x
      total += maybeButton.y
    }
  }
  return total
}

private data class Button(
    val x: Long,
    val y: Long,
)

private data class Machine(
    val buttonA: Button,
    val buttonB: Button,
    val prize: Button,
)

fun main() {
  val input = readFileAsList("13/input").filter { it.isNotEmpty() }
  val machines = mutableListOf<Machine>()
  val buttonRegex = Regex("X\\+(\\d+), Y\\+(\\d+)")
  val prizeRegex = Regex("X=(\\d+), Y=(\\d+)")
  var i = 0
  while (i < input.size) {
    val buttonAMatch = buttonRegex.find(input[i])!!
    val buttonA = Button(buttonAMatch.groupValues[1].toLong(), buttonAMatch.groupValues[2].toLong())
    val buttonBMatch = buttonRegex.find(input[i + 1])!!
    val buttonB = Button(buttonBMatch.groupValues[1].toLong(), buttonBMatch.groupValues[2].toLong())
    val prizeMatch = prizeRegex.find(input[i + 2])!!
    val prize = Button(prizeMatch.groupValues[1].toLong(), prizeMatch.groupValues[2].toLong())
    machines.add(Machine(buttonA, buttonB, prize))
    i += 3 // Empty lines are filtered, we only read 3 lines at a time
  }
  println("Part 1: ${partOne(machines)}")
  println("Part 2: ${partTwo(machines)}")
}
